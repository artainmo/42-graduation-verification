# 42-graduation-verification
A program that automatically verifies and displays to what extent a 42 network student validates the requirements for [the bachelor and master](https://meta.intra.42.fr/articles/19-requirements).

## Use

First download dependencies and follow the instructions to create a 42_API_ACCESS_TOKEN with the following command.
```
make setup
```

Now that you have the ACCESS_TOKEN use it as indicated here.
```
make ACCESS_TOKEN=<your-access-token> LOGIN=<your-login>
```
## Notes

In notes directory one can find more information about how much xp per hour projects give and as such what projects give the most xp. Also projects indicated as potential requirements that I did not found in 19's cursus.

## Warnings
In script mac's homebrew is used to install the dependencies.

Errors may be present or changes in requirements could happen in the future. Please let me know if a fix is necessary.
