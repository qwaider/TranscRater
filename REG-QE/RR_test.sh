#!/bin/bash Test RR for CHiME3

testFile=$1
modelsdir=$2
outfile=$3

  
printf "\nTest \"$modelsdir\" models on \"$testFile\"...\n"


cat $testFile | cut -d' ' -f1 > $BASEDIR/temp/RR/test.label
cat $testFile | tr ':' ' ' | awk '{for(i=5;i<=NF;i+=2) printf("%.4f ",$i); printf("\n")}' > $BASEDIR/temp/RR/test.feat
  
python $BINDIR/bin/XRT_REG_test.py $BASEDIR/temp/RR/test.feat $modelsdir $outfile 2>&1 | grep WriteNothing

if [[ ! `cat $BASEDIR/temp/RR/test.feat|wc -l` = `cat $outfile|wc -l` ]];
then
  printf "Error!!! WER Prediction Failed"
  return
fi

python $BINDIR/bin/compute_MAE.py $testFile $outfile



if [[ `echo  $CHANNELS'>'1 | bc -l` = 1 ]];
then

  python $BINDIR/bin/rank_array.py $BASEDIR/temp/RR/test.label $CHANNELS $BASEDIR/temp/RR/test.label.rank
  python $BINDIR/bin/rank_array.py $outfile $CHANNELS ${outfile}.rank

  python $BINDIR/bin/compute_NDCG.py  $BASEDIR/temp/RR/test.label.rank ${outfile}.rank

fi


