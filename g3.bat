rm -rf install
mkdir install
mkdir install\bin
cxfreeze --include-path=. --include-modules=Pmw wsjt.py --target-dir=install\bin
