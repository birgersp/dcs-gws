from pathlib import Path
from datetime import datetime
import subprocess
import time


def getFileTimestamp(file: Path) -> datetime:
    return datetime.fromtimestamp(file.stat().st_mtime)


def getNewestFileIn(dirName: str) -> Path:
    folder = Path(dirName)
    isFirstFile = True
    for f in folder.iterdir():
        if isFirstFile:
            newestFile = f
            newestFileTs = getFileTimestamp(newestFile)
            isFirstFile = False
            continue
        fileTs = getFileTimestamp(f)
        if (fileTs > newestFileTs):
            newestFile = f
            newestFileTs = fileTs
    return newestFile


def doBuild():
    subprocess.run(["powershell", "-Command", "ps/make.ps1"])


newestFile = getNewestFileIn("autogft")
doBuild()
while (True):
    time.sleep(1)
    file = getNewestFileIn("autogft")
    if getFileTimestamp(file) > getFileTimestamp(newestFile):
        doBuild()
        newestFile = file
