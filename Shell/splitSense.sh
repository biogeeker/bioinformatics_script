#!/usr/bin/env bash

# Get the bam file (1st argument) and output directory (2nd argument) from the command line
BAM=$1
TARGET_D=$2

FILE=$(basename $BAM)
NAME=$(basename $BAM)
BAMF1=${TARGET_D}/${NAME}.fwd1.bam
BAMF2=${TARGET_D}/${NAME}.fwd2.bam
BAMF=${TARGET_D}/${NAME}.fwd.bam
BAMR1=${TARGET_D}/${NAME}.rev1.bam
BAMR2=${TARGET_D}/${NAME}.rev2.bam
BAMR=${TARGET_D}/${NAME}.rev.bam

# Forward strand.
#
# 1\. alignments of the second in pair if they map to the forward strand
# 2\. alignments of the first in pair if they map to the reverse strand
#
# 0x1 - paired
# 0x2 - properly paired
# 0x20 - partner on reverse strand
# 0x40 - read one
# FLAGs 0x1 + 0x2 + 0x20 + 0x40 = 0x63 = 99 in decimal
samtools view -bh -f 99 $BAM > $BAMF1
samtools index $BAMF1
# 0x1 - paired
# 0x2 - properly paired
# 0x10 - on reverse strand
# 0x80 - read two
# FLAGs 0x1 + 0x2 + 0x10 + 0x80 = 0x93 = 147 in decimal
samtools view -bh -f 147 $BAM > $BAMF2
samtools index $BAMF2

#
# Combine alignments that originate on the forward strand.
#
samtools merge -f $BAMF $BAMF1 $BAMF2
samtools index $BAMF

# Reverse strand
#
# 1\. alignments of the second in pair if they map to the reverse strand
# 2\. alignments of the first in pair if they map to the forward strand
#

# 0x1 - paired
# 0x2 - properly paired
# 0x10 - reverse strand
# 0x40 - read one
# FLAGs 0x1 + 0x2 + 0x10 + 0x40 = 0x53 = 83 in decimal
samtools view -bh -f 83 $BAM > $BAMR1
samtools index $BAMR1
# 0x1 - paired
# 0x2 - properly paired
# 0x30 - partner on reverse strand
# 0x80 - read two
# FLAGs 0x1 + 0x2 + 0x20 + 0x80 = 0xA3 = 163 in decimal
samtools view -bh -f 163 $BAM > $BAMR2
samtools index $BAMR2

#
# Combine alignments that originate on the reverse strand.
#
samtools merge -f $BAMR $BAMR1 $BAMR2
samtools index $BAMR
