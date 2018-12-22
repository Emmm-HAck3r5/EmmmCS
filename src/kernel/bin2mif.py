import struct

conf = {
    'filename': "kernel.bin",
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
            s = 0
            for i in range(0, conf['word_bin']):
                try:
                    s = i
                    num = struct.unpack('H', Bin.read(2))[0]
                    File.write('{:x} : {:x};\n'.format(i, num))
                except:
                    break
            File.write('[{:x}..{:x}] : 0;\n'.format(s, conf['word_count'] - 1))
            File.write('END;\n')