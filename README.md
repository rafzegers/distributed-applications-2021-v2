# Assignment Distributed Applications 20-21

## Assignment

Read [assignment.md](assignment/assignment.md)

## Setup: Receiving updates

To be done once: add our project repo as an extra remote called `upstream`.

```bash
git remote add upstream https://github.com/distributed-applications-2021/assignment2021-v2
```

To be done at each update:

```bash
git pull upstream main
# If it complains about unrelated histories, execute the following command:
git pull upstream main --allow-unrelated-histories -X theirs
```

To be notified of updates, register as watcher [here](https://github.com/distributed-applications-2021/assignment2021-v2).
