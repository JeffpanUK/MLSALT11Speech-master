#!/bin/tcsh
#$ -S /bin/tcsh

# default parameters
set LMSCALE=12.0
set INSPEN=-10.0
set OUTPASS=decode
unset ADAPTSRC

set ALLARGS=($*)
set CHANGED
if ( $#argv > 1 ) then
while ( $?CHANGED )
  unset CHANGED
  if ( "$argv[1]" == "-LMSCALE" )  then
    set CHANGED
    shift argv
    set LMSCALE = $argv[1]
    shift argv
  endif
  if ( "$argv[1]" == "-INSPEN" )  then
    set CHANGED
    shift argv
    set INSPEN = $argv[1]
    shift argv
  endif
  if ( "$argv[1]" == "-ADAPT" )  then
    set CHANGED
    shift argv
    set ADAPTSRC = $argv[1]
    shift argv
    set ADAPTPASS = $argv[1]
    shift argv
  endif
  if ( "$argv[1]" == "-OUTPASS" )  then
    set CHANGED
    shift argv
    set OUTPASS = $argv[1]
    shift argv
  endif
end
endif

if ( $#argv != 5 ) then
   echo "usage: `basename $0` [-ADAPT SRC PASS] [-INSPEN -10.0] [-LMSCALE 12.0] [-OUTPASS decode] TESTSET SRC PASS TGT SYSTEM"
   echo "    system must be one of [ plp | hybrid | tandem ]"
   exit 0
endif

set TESTSET  = $1
set SRC      = $2
set PASS     = $3
set TGT      = $4
set SYSTEM   = $5

# cache the command so know what's run
if (! -d CMDs/$TGT/$TESTSET) mkdir -p CMDs/$TGT/$TESTSET
set TRAINSET=hmmrescore
echo "------------------------------------" >> CMDs/$TGT/$TESTSET/${TRAINSET}.cmds
echo "$0 $ALLARGS" >> CMDs/${TGT}/$TESTSET/${TRAINSET}.cmds
echo "------------------------------------" >> CMDs/$TGT/$TESTSET/${TRAINSET}.cmds


if ( $SYSTEM == "plp" ) then
    set HDECODE = base/bin/HDecode 
    set MMF = hmms/MMF.${SYSTEM}
    set SCP = lib/flists/${TESTSET}.scp 
    set CFG = lib/cfgs/hdecode.cfg
    set DICT    = lib/dicts/train.lv.dct
    set PRUNE = ( -t 250.0 250.0 -v 175.0 135.0 -u 10000 -n 32 )
else if (( $SYSTEM == "tandem" ) || ( $SYSTEM == "tandem-sat" ))then
    set HDECODE = base/bin/HDecode 
    set MMF = hmms/MMF.${SYSTEM}
    set SCP = lib/flists_tandem/${TESTSET}.scp 
    set CFG = lib/cfgs/hdecode_tandem.cfg
    set DICT    = lib/dicts/train.lv.dct
    set PRUNE = ( -t 400.0 400.0 -v 250.0 200.0 -u 10000 -n 32 )
else if ( $SYSTEM == "hybrid" ) then
    if ( $?ADAPTSRC ) then 
        echo "Adaptation not supported for hybrid systems"
        exit 0
    endif
    set HDECODE = base/bin/HDecode.mkl
    set MMF = hmms/MMF.${SYSTEM}
    set SCP = lib/flists/${TESTSET}.scp 
    set CFG = lib/cfgs/hdecode_hybrid.cfg
    set DICT    = lib/dicts/train.lv.dct
    set PRUNE = ( -t 250.0 250.0 -v 175.0 135.0 -u 10000 -n 32 )
else if ( $SYSTEM == "grph-plp" ) then
    set HDECODE = base/bin/HDecode 
    set MMF = hmms/MMF.${SYSTEM}
    set SCP = lib/flists/${TESTSET}.scp 
    set CFG = lib/cfgs/hdecode.cfg
    set DICT    = lib/dicts/train-grph.lv.dct
    set PRUNE = ( -t 250.0 250.0 -v 175.0 135.0 -u 10000 -n 32 )
else if ( $SYSTEM == "grph-tandem" ) then
    set HDECODE = base/bin/HDecode 
    set MMF = hmms/MMF.${SYSTEM}
    set SCP = lib/flists_tandem/${TESTSET}.scp 
    set CFG = lib/cfgs/hdecode_tandem.cfg
    set DICT    = lib/dicts/train-grph.lv.dct
    set PRUNE = ( -t 400.0 400.0 -v 250.0 200.0 -u 10000 -n 32 )
else
    echo "Unknown system kind: $SYSTEM"
    exit 0
endif

if (! -d $SRC/$TESTSET/$PASS/lattices) then 
  echo "Lattice directory missing: $SRC/$TESTSET/$PASS/lattices"
  exit 0;
endif

set WORKDIR=${TGT}/${TESTSET}/$OUTPASS
if (! -d $WORKDIR/lattices) then 
    mkdir -p $WORKDIR/lattices
    mkdir -p $WORKDIR/flists
else 
    echo "Directory exists: $WORKDIR"
    echo "Delete to run"
    exit 0
endif

if ( $?ADAPTSRC ) then

cat > $WORKDIR/run.bat <<EOF 
#!/bin/bash

#\$ -S /bin/bash

source  /opt/intel/composerxe/bin/compilervars.sh intel64

# some lattices may not exist - generate the list of lattices to avoid HDecode crashing
 ./scripts/lats2scp $SRC/${TESTSET}/$PASS/lattices $SCP ${WORKDIR}/flists/${TESTSET}.scp

# run the decoding making use of the adaptation transforms
$HDECODE -A -D -V -i $WORKDIR/rescore.mlf -H $MMF -s $LMSCALE -p $INSPEN  \
    -X rec -T 1 $PRUNE -m -J $ADAPTSRC/$TESTSET/$ADAPTPASS/xforms mllr -J lib/classes -C lib/cfgs/cmllr.cfg \
    -z lat -l $WORKDIR/lattices  -h "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%_*" \
    -C $CFG -X lat -w -L $SRC/$TESTSET/$PASS/lattices -S ${WORKDIR}/flists/${TESTSET}.scp $DICT hmms/xwrd.clustered.$SYSTEM >& $WORKDIR/LOG
EOF

else 

cat > $WORKDIR/run.bat  <<EOF
#!/bin/bash

#\$ -S /bin/bash

source /opt/intel/composerxe/bin/compilervars.sh intel64

# some lattices may not exist - generate the list of lattices to avoid HDecode crashing
 ./scripts/lats2scp $SRC/${TESTSET}/$PASS/lattices $SCP ${WORKDIR}/flists/${TESTSET}.scp

# run the decoding 
$HDECODE -A -D -V -i $WORKDIR/rescore.mlf -H $MMF -s $LMSCALE -p $INSPEN \\
    -X rec -T 1 $PRUNE \
    -z lat -l $WORKDIR/lattices \
    -C $CFG -X lat -w -L $SRC/$TESTSET/$PASS/lattices -S ${WORKDIR}/flists/${TESTSET}.scp $DICT hmms/xwrd.clustered.$SYSTEM >& $WORKDIR/LOG
EOF

endif

chmod u+x $WORKDIR/run.bat
qsub -S /bin/bash -cwd -o $WORKDIR/run.LOG -j y $WORKDIR/run.bat

