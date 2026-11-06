"""Reproducible F411 build, reusing local lab HAL/FreeRTOS/USB.
No downloads, no writes to the lab, no board flashing. Python 3.9+.
"""
import argparse
import json
from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--base', type=Path, help='ex_Barry_USB_STM32F411CE directory')
parser.add_argument('--cc', default='arm-none-eabi-gcc')
parser.add_argument('--profile', choices=['unconfigured', 'kit-bancada', 'kit-operacao'], default='unconfigured')
parser.add_argument('--hardware', type=Path, help='Reviewed hardware record for kit-operacao only')
args = parser.parse_args()
kit = args.profile.startswith('kit-')
power_flags = []
if args.profile == 'kit-operacao':
    if not args.hardware:
        parser.error('kit-operacao requires --hardware with the completed hardware record')
    try:
        record = json.loads(args.hardware.read_text(encoding='utf-8-sig'))
    except (OSError, ValueError) as err:
        parser.error(str(err))
    if not isinstance(record, dict):
        parser.error('hardware record must be a JSON object')
    for key in ('motor', 'transmissao', 'fonte', 'retencao', 'corte_independente', 'registro_bancada'):
        if not isinstance(record.get(key), str) or not record[key].strip():
            parser.error(f'missing hardware identification: {key}')
    if record.get('perfil_verificado') != 'F411CEU6-25MHz-TB6612FNG-20kHz':
        parser.error('this driver requires the verified F411/TB6612 bench profile')
    for key, macro, maximum in [('referencia_pct', 'EL_PWM_HOME', 100),
                                ('viagem_pct', 'EL_PWM_TRAVEL', 100),
                                ('teto_pct', 'EL_PWM_MAX', 100),
                                ('rampa_pct_s', 'EL_RAMP_PER_SECOND', 100),
                                ('reversao_ms', 'EL_REVERSE_MS', 60000)]:
        value = record.get(key)
        if type(value) is not int or not 1 <= value <= maximum:
            parser.error(f'{key} must be an integer between 1 and {maximum}')
        power_flags.append(f'-D{macro}={value if key == "reversao_ms" else value * 10}u')
    if max(record['referencia_pct'], record['viagem_pct']) > record['teto_pct']:
        parser.error('reference and travel PWM exceed the hardware ceiling')
    power_flags.append('-DKIT_POWER_COMMISSIONED')
elif args.hardware:
    parser.error('--hardware applies only to kit-operacao')
base = args.base or next((p for p in [
    ROOT / 'arquivo/publicacao-mic2/ex_Barry_USB_STM32F411CE',
    ROOT.parent / 'ex_Barry_USB_STM32F411CE',
    ROOT.parent / 'labRTOS/ex_Barry_USB_STM32F411CE',
    ROOT.parent.parent / 'MIC2/labRTOS/ex_Barry_USB_STM32F411CE'
] if p.is_dir()), None)
if base is None:
    parser.error('Provide --base with the existing STM32F411 laboratory directory')
base = base.resolve()
cc = shutil.which(args.cc) or args.cc
out = ROOT / 'build/f411'
if kit:
    out = out / args.profile
out.mkdir(parents=True, exist_ok=True)
kernel = base / 'Middlewares/Third_Party/FreeRTOS/Source'
usb = base / 'Middlewares/ST/STM32_USB_Device_Library'
includes = [ROOT/'ports/stm32f411', ROOT/'include', base/'Core/Inc',
    base/'Drivers/STM32F4xx_HAL_Driver/Inc', base/'Drivers/CMSIS/Include',
    base/'Drivers/CMSIS/Device/ST/STM32F4xx/Include', kernel/'include',
    kernel/'portable/GCC/ARM_CM4F', kernel/'CMSIS_RTOS',
    usb/'Core/Inc', usb/'Class/CDC/Inc', base/'USB_DEVICE/App', base/'USB_DEVICE/Target']
sources = list((ROOT/'src').glob('*.c')) + list((ROOT/'ports/stm32f411').glob('*.c'))
if kit:
    sources.remove(ROOT/'ports/stm32f411/board_unconfigured.c')
    sources += sorted((ROOT/'ports/stm32f411/kit').glob('*.c'))
project_sources = set(sources)
sources += [base/'Core/Src'/name for name in ['stm32f4xx_hal_msp.c', 'stm32f4xx_hal_timebase_tim.c',
    'stm32f4xx_it.c', 'syscalls.c', 'sysmem.c', 'system_stm32f4xx.c']]
sources += list((base/'Core/Startup').glob('*.s'))
sources += list((base/'Drivers/STM32F4xx_HAL_Driver/Src').glob('*.c'))
sources += list(kernel.glob('*.c')) + [kernel/'portable/GCC/ARM_CM4F/port.c', kernel/'portable/MemMang/heap_4.c']
sources += list((kernel/'CMSIS_RTOS').glob('*.c'))
for folder in [usb/'Core/Src', usb/'Class/CDC/Src', base/'USB_DEVICE/App', base/'USB_DEVICE/Target']:
    sources += list(folder.glob('*.c'))
machine = ['-mcpu=cortex-m4', '-mthumb', '-mfpu=fpv4-sp-d16', '-mfloat-abi=hard']
common = machine + ['-std=gnu11', '-Os', '-g3', '-ffunction-sections', '-fdata-sections',
    '-Wall', '-Wextra', '-DUSE_HAL_DRIVER', '-DSTM32F411xE', '-DHSE_VALUE=25000000']
common += [f'-I{p}' for p in includes]
common += power_flags
objects = []
for index, src in enumerate(sources):
    obj = out / f'{index:03d}_{src.stem}.o'
    flags = ['-Werror'] if src in project_sources else []
    if kit and src.name == 'stm32f4xx_it.c':
        # Keep USB and TIM4 vectors from the lab. The kit supplies fault handlers.
        flags += [f'-D{name}_Handler=lab_{name}_Handler'
                  for name in ('NMI', 'HardFault', 'MemManage', 'BusFault', 'UsageFault')]
    subprocess.run([cc, *common, *flags, '-c', str(src), '-o', str(obj)], check=True)
    objects.append(str(obj))
linker = base/'STM32F411CEUX_FLASH.ld'
elf = out/f'elevador-{args.profile}.elf'
subprocess.run([cc, *machine, *objects, f'-T{linker}', '--specs=nano.specs', '--specs=nosys.specs',
    '-Wl,--gc-sections', f'-Wl,-Map={out / "elevador.map"}', '-Wl,--start-group', '-lc', '-lm',
    '-Wl,--end-group', '-o', str(elf)], check=True)
size = str(cc).replace('gcc', 'size')
subprocess.run([size, str(elf)], check=True)
hex_file = elf.with_suffix('.hex')
objcopy = str(Path(cc).with_name(Path(cc).name.replace('gcc', 'objcopy')))
subprocess.run([objcopy, '-O', 'ihex', str(elf), str(hex_file)], check=True)
print(f'Linked {len(objects)} objects: {elf}')
print(f'Flash image: {hex_file}')
print({'kit-bancada': 'Bench signals only, STBY held low.',
       'kit-operacao': 'POWER PROFILE: built using the supplied hardware record.',
       'unconfigured': 'UNCONFIGURED BOARD: all elevator outputs inactive.'}[args.profile])
