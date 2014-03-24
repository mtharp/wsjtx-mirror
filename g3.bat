rm -rf install
mkdir install
mkdir install\bin
python ..\..\Python33\Scripts\cxfreeze --include-path=. --include-modules=Pmw wsjt.py --target-dir=install\bin
