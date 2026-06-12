# RedBearLab Blend Micro — soporte para Arduino IDE 2.x

Paquete de placas **no oficial** que rescata el soporte de la RedBearLab Blend Micro
(ATmega32U4 + nRF8001) para Arduino IDE 2.x, arduino-cli y versiones futuras.

El paquete original de RedBearLab solo funciona en IDE 1.x porque define un toolchain
propio con rutas internas del IDE antiguo. Este paquete delega el toolchain en el core
oficial `arduino:avr`, por lo que no vuelve a romperse con las actualizaciones del IDE.

## Instalación

1. Arduino IDE → **Archivo → Preferencias → URLs adicionales de gestor de placas**, añadir:

   ```
   https://raw.githubusercontent.com/sebasdv/blend-micro-boards/master/package_redbearlab_index.json
   ```

2. **Herramientas → Placa → Gestor de placas**, buscar `Blend Micro` e instalar
   **RedBearLab AVR Boards (Blend Micro)**.
3. Asegúrate de tener instalado **Arduino AVR Boards** (core oficial; el IDE lo trae
   por defecto). Este paquete lo necesita.
4. Para sketches de teclado/ratón USB, instala la librería oficial **Keyboard** (y/o
   **Mouse**) desde el Gestor de librerías — no viene incluida con el core.
5. Selecciona **Blend Micro 3.3V/8MHz** (o 16MHz) y el puerto COM.

> **Si tienes el paquete RedBearLab original instalado** (aparece como
> `RedBear AVR Boards` / placas `RedBear:avr:*` en el Gestor de placas),
> desinstálalo para evitar confusiones: ese es el paquete roto de IDE 1.x.
> Este paquete usa el vendor `redbearlab`, así que no chocan entre sí.

## Qué incluye

- Placas `redbearlab:avr:blendmicro8` y `redbearlab:avr:blendmicro16`, con los
  parámetros originales (VID/PID 0x03EB:0x2404, bootloader Caterina, fuses).
- **Corrección de reloj fiel a la original**: el modo 8 MHz corrige el PLL USB
  (la placa tiene cristal de 16 MHz) y el modo 16 MHz desactiva el prescaler del
  bootloader (overclock a 3.3 V). Sin esto el USB no enumera; se aplica
  automáticamente al compilar mediante un hook de la plataforma.
- Bootloader Caterina original («Quemar bootloader» funciona con los fuses originales).
- Librerías BLE embebidas, disponibles automáticamente al seleccionar la placa:
  - **BLE SDK for Arduino** (Nordic nRF8001 SDK, 22 ejemplos)
  - **RBL_nRF8001** (API de alto nivel de RedBearLab, 7 ejemplos)

### Dependencias de algunos ejemplos BLE

Los 7 ejemplos de RBL_nRF8001 compilan en ambas velocidades. Algunos requieren
librerías oficiales adicionales (Gestor de librerías):

| Ejemplo | Requiere |
|---|---|
| BLEControllerSketch, SimpleControls | Servo |
| BLEFirmataSketch | Firmata, Servo |
| BLE_SD | SD |

## Subir un sketch

Igual que un Arduino Leonardo: el bootloader entra automáticamente vía el puerto a
1200 bps. Si la subida no arranca, pulsa reset en la placa justo cuando el IDE
muestre «Subiendo...».

## Estructura del repositorio

- `redbearlab/avr/` — la plataforma (esto es lo que instala el Gestor de placas)
- `package_redbearlab_index.json` — índice para el Gestor de placas
- `scripts/package.ps1` — genera el ZIP del release y actualiza checksum/tamaño
- `tests/sketches/KeypadHID/` — sketch de verificación (teclado USB HID de 4 teclas)

## Créditos y licencias

- Plataforma y bootloader originales: [RedBearLab/Blend](https://github.com/RedBearLab/Blend)
- Librería BLE de alto nivel: [RedBearLab/nRF8001](https://github.com/RedBearLab/nRF8001)
- Nordic BLE SDK: [Cheong2K/ble-sdk-arduino](https://github.com/Cheong2K/ble-sdk-arduino)
  ([NordicSemiconductor/ble-sdk-arduino](https://github.com/NordicSemiconductor/ble-sdk-arduino))

Cada librería conserva su licencia original (ver sus carpetas). Este repositorio
solo moderniza la integración con el IDE.
