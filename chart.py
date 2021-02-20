#!/usr/bin/env python3

import json
import os
import re
import sys

import pandas as pd
import seaborn as sns


def get_data():
    data = []
    for filename in os.listdir("results"):
        if match := re.match(
            r"load_rust-(?P<rust>\d+.\d+.\d+)_sheldon-(?P<sheldon>\d+.\d+.\d+).json",
            filename,
        ):
            info = match.groupdict()
            info['versions'] = 'v{rust}\nv{sheldon}'.format(**info)
            with open(os.path.join("results", filename), "r") as f:
                results = json.load(f)["results"]
                assert len(results) == 1
                file_data = results[0]
                file_data.update(info)
                data.append(file_data)

    data.sort(key=lambda d: (d["sheldon"], d["rust"]))

    return pd.concat(pd.DataFrame(d) for d in data)


def chart():
    df = get_data()
    sns.set()

    # g = sns.scatterplot(x="sheldon", y="times", palette="pastel")
    g = sns.scatterplot(data=df, x="versions", y="times", palette="pastel")

    g.set(
        title=f"Load time",
        xlabel="",
        ylabel="Time taken (secs)",
    )
    filename = f"results/output.png"

    getattr(g, 'fig', getattr(g, 'figure', None)).savefig(filename)

    return filename


if __name__ == "__main__":
    print(f"Output chart to {chart()}")
