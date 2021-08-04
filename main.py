import math
import sys


def wsprmsg(filename=None):
    wsprmsg_list = []
    try:
        with open(filename, 'r') as file:
            for line in file:
                line = line.rstrip() # remove new line
                line = line.split(',') # split on comma
                while ("" in line):
                    line.remove("")
                map_object = map(int, line) # convert to int
                list_of_int = list(map_object)
                wsprmsg_list.extend(list_of_int)
        return wsprmsg_list
    except FileNotFoundError:
        print(f'File {filename} not found.')
        sys.exit(1)


def main():
    filename = 'WSPRMSG.txt'

    # Vpp value (modulation 100%)
    vpp = 6.000000

    # Points in waveform
    points = 8192

    # Arb wave Frame in msec
    frame_sec = 120000

    wspr_symbol_ms = 683
    wspr_points_per_symbol = math.floor(wspr_symbol_ms * points / frame_sec)

    symbol_value = {
        0: -vpp,
        1: (vpp * 2) / 3 - vpp,
        2: (vpp * 2) / 2 - vpp,
        3: (vpp * 2) / 1 - vpp,
    }

    wspmsg_output = wsprmsg(filename=filename)

    header = f"""data length,{points}
frequency,8.333000
amp,{vpp * 2}
offset,0.000000
phase,0.000000







xpos,value
"""

    with open('wspr.csv', 'w') as file:
        file.write(header)

        xpos = 1
        for symbol in wspmsg_output:
            for i in range(wspr_points_per_symbol):
                file.write(f'{xpos},{symbol_value[symbol]}\n')
                xpos += 1

        # write zero for the rest of the frame
        for i in range(xpos, points + 1):

            file.write(f'{xpos},{symbol_value[0]}\n')
            xpos += 1


if __name__ == "__main__":
    main()