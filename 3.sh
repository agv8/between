!/bin/bash

# Compilar codigo C++ en una librería compartida
g++ -c -fPIC one.cpp
g++ -shared -o one.so one.o

# Generamos la código envoltura SWIG en Python
swig -python -c++ -I. one.i

# Compilar envoltura SWIG en un módulo Python
python_config_cflags=$(python-config --cflags)
g++ -c -fPIC $python_config_cflags one_wrap.cxx
g++ -shared one_wrap.o one.so -o _one.so $python_config_cflags

# Crear directorio para el paquete Python
mkdir -p one_package/one

# Copiar modulo Python en el directorio
cp _one.so one_package/one/

# Copiar el archivo __init__.py en el directorio
echo "from ._one import *" > one_package/one/__init__.py

# Creamos un archivo setup.py para el paquete
echo "from setuptools import setup, Extension" > one_package/setup.py
echo "setup(name='one', version='1.0', ext_modules=[Extension('one._one', ['one/_one.so'])])" >> one_package/setup.py

# Creamos el paquete
cd one_package
python setup.py sdist bdist_wheel

# Limpiamos los archivos temporales
rm -rf one.o one.so one_wrap.cxx one_wrap.o _one.so build one.egg-info