# siglent-sdg-wspr
Proof of concept for transmitting WSPR with a Siglent Function / 
Arbitrary Waveform Generator. Tested with Siglent SDG-1032X. Channel 2 
is the FM source for channel 1.

Inspired by http://www.arrl.org/files/file/QEX_Next_Issue/May-June2019/Steber.pdf

My HF 0 dBm (1 mW) signal into an endfed sloper antenna was heard a few 
hundred to 1500 km away!

**Note:** You'll probably need an amateur radio license 
to transmit on HF! Also check your output for harmonics and use an LPF if 
necessary.

## Usage
### Generate the arbitrary gate waveform 
- Generate a WSPR message with WSPRMSG.exe, remove everything except the comma seperated values.
- Save file as WSPRMSG.txt in this directory.
- Run `main.py`, it will write a `wspr.csv` file.
- Optional: rename this file to something useful, for example `wspr0dBm.csv`.
- `wspr0dBm.csv` becomes waveform 'wspr0dBm' in the SDG.
- Load `wspr0dBm.csv` into EasyWaveX and upload it to the generator:

![Alt text](/images/EasyWaveX.png?raw=true "arb wspr waveform")

### Connect the instrument
- Connect an HF antenna to channel 1.
- Connect channel 2 to the aux input on the back of the instrument.
- Connect a 10 MHz reference. This results in a stable signal.

### Run the sdg-wspr.sh script
- Install lxi-tools (Ubuntu): `snap install lxi-tools`
- Find your device: `lxi discover`
- Get the waveform name: `lxi scpi -a <IP address> "STL? USER"`
- Edit at least the variables below in `sdg-wsrp.sh`
  - `address`: SDG IP address
  - `freq`: frequency in Herz.
  - `ampl`: amplitude in Vpp.
  - `wave`: waveform name.
- Run `sdg-wspr.sh`
