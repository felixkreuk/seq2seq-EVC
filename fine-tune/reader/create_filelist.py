import argparse
from pathlib import Path
import numpy as np

parser = argparse.ArgumentParser()
parser.add_argument("data", type=Path)
args = parser.parse_args()

train_tsv = [l.split("\t")[0].split("/")[-1].split(".")[0] for l in open(args.data / "train.tsv").readlines()[1:]]
valid_tsv = [l.split("\t")[0].split("/")[-1].split(".")[0] for l in open(args.data / "valid.tsv").readlines()[1:]]
test_tsv = [l.split("\t")[0].split("/")[-1].split(".")[0] for l in open(args.data / "test.tsv").readlines()[1:]]

train, val, test = [], [], []

for f in args.data.glob("**/*.wav"):
    name = f.stem
    mel = str(f).replace(".wav", ".mel.npy")
    phn = str(f).replace(".wav", ".phones")

    n_mel_frames = np.load(mel).shape[0]
    n_phones = len(open(phn, "r").read().strip().split(" "))

    if name in train_tsv:
        train += [f"{mel} {n_mel_frames} {n_phones}\n"]
    elif name in valid_tsv:
        val += [f"{mel} {n_mel_frames} {n_phones}\n"]
    if name in test_tsv:
        test += [f"{mel} {n_mel_frames} {n_phones}\n"]

open(args.data / "train_filelist.txt", "w").writelines(train)
open(args.data / "valid_filelist.txt", "w").writelines(val)
open(args.data / "test_filelist.txt", "w").writelines(test)
