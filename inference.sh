#!/bin/bash

data=$1
model=$2
src="Neutral"
trg="Sleepy"

model_dir=$(dirname $2)
model_name=$(basename $2)

echo "generating emotion embeddings..."
python conversion/inference_embedding.py \
    -c $model \
    --hparams speaker_A='Neutral',speaker_B='Amused',speaker_C='Angry',speaker_D='Sleepy',speaker_E='Disgusted',\
training_list="$data/valid_filelist.txt",\
a_embedding_path="conversion/zero_embeddings.npy",\
b_embedding_path="conversion/zero_embeddings.npy",\
c_embedding_path="conversion/zero_embeddings.npy",\
d_embedding_path="conversion/zero_embeddings.npy",\
e_embedding_path="conversion/zero_embeddings.npy",\
SC_kernel_size=1

for trg in "Neutral" "Amused" "Angry" "Sleepy" "Disgusted"; do
# for trg in "Neutral"; do
echo "running inference $src $trg..."
python conversion/inference_A.py \
    -c $model \
    --num 5 \
    --hparams \
training_list="$data/train_filelist.txt",\
validation_list="$data/valid_filelist.txt",\
mel_mean_std="$data/mel_mean_std.npy",\
speaker_A="$src",speaker_B="$trg",\
a_embedding_path="$model_dir/embeddings/Neutral.npy",\
b_embedding_path="$model_dir/embeddings/Amused.npy",\
c_embedding_path="$model_dir/embeddings/Angry.npy",\
d_embedding_path="$model_dir/embeddings/Sleepy.npy",\
e_embedding_path="$model_dir/embeddings/Disgusted.npy",\
SC_kernel_size=1
done

echo "synthesizing..."
echo $model_dir
echo $model_name
arrIN=(${model_name//_/ })
iter=${arrIN[1]}
echo $iter

tmpfile=$(mktemp /tmp/seq2seq-evc-generated.XXXXXX)
echo $tmpfile

for emotion_pair_dir in $model_dir/test_$iter/vc_*; do
    echo "generating $emotion_pair_dir"

    /home/mlspeech/felixk/anaconda3/envs/hifigan/bin/python \
        /home/mlspeech/felixk/workspace/hifi-gan/inference_e2e.py \
        --checkpoint_file /data/felix/models/hifigan/emov_from_scratch_200hop_norm1/g_00065000 \
        --input_mels_dir $emotion_pair_dir/mel \
        --output_dir $emotion_pair_dir/hifigan_wavs

    /home/mlspeech/felixk/anaconda3/envs/hifigan/bin/python \
        /home/mlspeech/felixk/workspace/hifi-gan/inference_e2e.py \
        --checkpoint_file /data/felix/models/hifigan/emov_from_scratch_200hop_norm1/g_00065000 \
        --input_mels_dir $emotion_pair_dir/orig_mels \
        --output_dir $emotion_pair_dir/orig_mels_hifigan_wavs

    find $emotion_pair_dir -iname "*.npy" \
        | awk '{split ($1,x,/\//); print x[10] " " $1}' > $tmpfile
    /home/mlspeech/felixk/anaconda3/envs/pwg/bin/python \
        /home/mlspeech/felixk/anaconda3/envs/pwg/bin/parallel-wavegan-decode \
        --feats-scp $tmpfile \
        --outdir $emotion_pair_dir/pwg_wavs \
        --checkpoint /data/felix/models/pwg/jnas_pwg/checkpoint-400000steps.pkl \
        --config /data/felix/models/pwg/jnas_pwg/config.yml
done
rm $tmpfile
