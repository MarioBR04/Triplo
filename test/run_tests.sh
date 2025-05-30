#!/bin/bash

# Limpiar cobertura anterior
rm -rf coverage

# Ejecutar todas las pruebas con cobertura
flutter test --coverage

# Generar reporte HTML de cobertura
genhtml coverage/lcov.info -o coverage/html

# Mostrar resumen de cobertura
lcov --summary coverage/lcov.info

# Abrir el reporte en el navegador (macOS)
open coverage/html/index.html

# Ejecutar pruebas de rendimiento
flutter test test/performance/app_perf_test.dart

echo "Tests completados. El reporte de cobertura está disponible en coverage/html/index.html" 