# Getting started

PixeneOS is a bash script for patching GrapheneOS OTA images with custom modules.
This tool offers many features which are highly dependent on upstream projects.

Linux based OS is recommended.

To get started, clone the repository and run the following commands:

- Modify `env.toml` file to set the environment variables
- To run the program E2E (end to end), execute the following command:

  ```bash
  source src/main.sh --local
  ```

  > [!IMPORTANT]
  > Make sure that `env.toml` file exist in root of the project.

  `local` command calls `check_toml_env` function to check if `env.toml` file exists in root of the project and if it exist, it will read the toml file and set the environment variables accordingly.

## Commands

- Execute the following command to see the list of available commands and other helpful information:

  ```bash
  source src/util_functions.sh && help
  ```

  `help` command will display the help message.

## Execution

To call individual functions / commands, execute the following command:

```bash
source  src/<file>.sh && <function_name>
```
