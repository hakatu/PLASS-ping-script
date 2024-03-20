
The script will perform its checks on the predefined hosts and output the results, including any detected spikes, to `plwatch.txt` in the same directory.

### Configuration

You can configure the script by editing the `HOSTS` and `COUNT` variables at the beginning of the script:

- `HOSTS` - Add the IP addresses or hostnames of the servers you wish to monitor, separated by space.
- `COUNT` - Adjust the number of ping requests to send to each host.

## License

This project is licensed under the GNU GENERAL PUBLIC LICENSE - see the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgments

- Inspired by nixCraft's approach to simple network monitoring with ping commands.
- Thanks to all contributors who have helped to enhance this script.

