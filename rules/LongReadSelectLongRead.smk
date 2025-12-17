import os
directory="output"
if not os.path.exists(directory):
    os.makedirs(directory)
directory="output/secondrun"
if not os.path.exists(directory):
    os.makedirs(directory)

rule select_longread:
    input:
        raw=config['longread']
    output:
        long="output/filter_length.fq",
        short="output/left_filter_length.fq"
    threads:
        1
    params:
        config['genomesize']
    shell:
        """
        python scripts/SelectLongRead.py {input.raw} {params} {output.long} {output.short}
        """

rule fq_to_fa:
    input:
        "output/filter_length.fq"
    output:
        "output/filter_length.fa"
    threads:
        1
    shell:
        """
        python scripts/FqToFa.py {input} {output}
        """

##longRead_correct
par=""
readType=config['readtype']
if readType=="ONT":
    par="map-ont"
else:
    par="map-pb"

rule short_to_long:
    input:
        long = "output/filter_length.fa",
        short = "output/left_filter_length.fq"
    output:
        "output/short_to_long.sam"
    threads:
        config["threads"]
    params:
        type=par
    shell:
        """
        minimap2 -ax {params.type} -t {threads} {input.long} {input.short} > {output}
        """
rule longread_polish:
    input:
        long = 'output/filter_length.fa',
        short = 'output/left_filter_length.fq',
        sam = 'output/short_to_long.sam'
    threads:
        config["threads"] // 2
    output:
        "output/long_read_corrected.fasta"
    shell:
        """
        racon --threads {threads} {input.short} {input.sam} {input.long} > {output}
        """
