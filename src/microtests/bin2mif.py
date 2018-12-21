import struct

conf = {
    'filename': "main.bin",
    'output': "cache.mif",
    'word_len': 16,
    'word_count': 262144,
    'word_bin': 0x10000
}

def write_head(File):
    File.write(f"WIDTH={conf['word_len']};\n")
    File.write(f"DEPTH={conf['word_count']};\n")
    File.write("ADDRESS_RADIX=HEX;\n")
    File.write("DATA_RADIX=HEX;\n")
    File.write("CONTENT\n")
    File.write("BEGIN\n")

if __name__ == "__main__":
    with open(conf['output'], "w") as File:
        write_head(File)
        with open(conf['filename'], "rb") as Bin:
            for i in range(0, conf['word_bin']):
                try:
                    num = struct.unpack('H', Bin.read(2))[0]
                    File.write('{:x} : {:x};\n'.format(i, num))
                except:
                    pass
            File.write('[{:x}..{:x}] : 0;\n'.format(conf['word_bin'], conf['word_count'] - 1))
            File.write('END;\n')