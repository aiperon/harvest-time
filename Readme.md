
# Harvest Time

The Harvest Time is a CLI program that allows you to export time tracking data from your [Harvest](https://getharvest.com) account to a CSV file or json format. This tool is designed to make it easy for users to retrieve and analyze time tracking data for specific projects and date ranges.

## Motivation
I use Harvest for time tracking for a few years. Sometimes I need to export time reports, slightly modify them, and send them to my clients. I found the tools like [gem harvesting](https://github.com/fastruby/harvesting/tree/main) and [hrvst-cli](https://kgajera.github.io/hrvst-cli/) could help me with it, but they also require  some coding to make the things done. These changes doesn't looked like a feature for the existed projects. I decided to write my own tool from the scratch with a few principles:
- it should be easily installed
- it should be easily configurable
- it should works as a CLI tool in an one-click manner
- it should works fast
- it should demonstrates my coding skills

## Installation
To get started with the Harvest Time, follow these steps:

1. **Prerequisites:**
   - Make sure you have Ruby 2.6.9 or higher installed on your machine.

2. **Clone the Repository:**
   ```bash
   git clone https://github.com/aiperon/harvest-time.git
   cd harvest-time
   ```
3. **Fill in the Environment file**
    - Copy `.env.example` to `.env`
    - Retrieve your Harvest API token from your [Harvest account](https://id.getharvest.com/oauth2/access_tokens/new)
    - Fill in the values for your Harvest account id and access token in the `.env` file.

4. **Install Dependencies:**
   ```bash
   gem install dotenv
   ```

## Usage

```bash
# Time report for all projects on the current month:
bin/harvest-time

# Time report for the certian project on the previous month:
bin/harvest-time --prev -p ProjectName

# Time report exported to the csv file with verbose output:
bin/harvest-time -v --output report.csv

# Get the time report for a specific tasks on specific period:
bin/harvest-time --tasks TaskName1,TaskName2,"Task Name 3" --from 2023-09-01 --to 2023-10-31
```

Note: if project or tasks names are specified, then the command will try to find the exact match.
Additionally, in verbose mode, the command will output the list of found projects and tasks names.


## Options

The following options are available:

| Option | Description | Default |
| ---:| --- | --- |
| -p, --project | The name of the project to export time entries for  | All projects |
| --from | Time entries from date (yyyy-mm-dd) | Beginning of the current month |
| --to | Time entries to date (yyyy-mm-dd) | End of the current month |
| --prev | Time entries from the previous month. It overrides `from` and `to` options. | false |
| --output | Output filename (accepts csv or json extensions) | stdout |
| -v, --verbose | Addition log messages | false |

## Roadmap

- [ ] Turn it to the gem for easy installation
- [ ] Configurable export fields. Currently, it's hardcoded in Formatter class.
- [ ] Remove dotenv dependency for usage without installation
- [ ] Add templates option for frequently used options
- [ ] Add the command to generate invoices


## License

The Harvest Time Exporter is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).