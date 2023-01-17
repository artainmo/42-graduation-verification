# 42-graduation-verification
A program that verifies and displays to what extent a 42 network student validates the requirements for [the bachelor and master](https://meta.intra.42.fr/articles/19-requirements).

## Use

First download dependencies and follow the instructions to create a 42_API_ACCESS_TOKEN with the following command.
```
make setup
```

Now that you have the ACCESS_TOKEN use it as indicated here.
```
make ACCESS_TOKEN=<your-access-token>
```

## Warnings
In script mac's homebrew is used to install the dependencies.

Errors may be present or changes in requirements could happen in the future. Please let me know if a fix is necessary.

If 'jq' creates error messages and makes the application bug, simply stop and relaunch the application.
