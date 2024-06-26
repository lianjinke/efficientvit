#!/bin/bash

source activate efficientvit

cd ~/efficientvit

export NCCL_IB_SL=1
export CUDA_DEVICE_MAX_CONNECTIONS=1
export NCCL_ASYNC_ERROR_HANDLING=1

export WANDB_RUN_ID="efficientvit_sam_xl1"
export WANDB_RESUME="allow"

CONFIG_PATH="configs/sam/xl1.yaml"
LOG_PATH=".exp/sam/efficientvit_sam_xl1"

master_addr=$(scontrol show hostnames "$SLURM_JOB_NODELIST" | head -n 1)
export MASTER_ADDR=${master_addr:-"127.0.0.1"}
export CURRENT_RANK=${SLURM_PROCID:-"0"}
worker_list=$(scontrol show hostnames "$SLURM_JOB_NODELIST" | tr '\n' ' ')
n_node=${SLURM_JOB_NUM_NODES:-1}

echo "MASTER_ADDR="$MASTER_ADDR
echo "JobID: $SLURM_JOB_ID | Full list: $worker_list"

torchrun --nnodes=$n_node --nproc_per_node=8 --master_port=25001 \
    --master_addr $MASTER_ADDR --node_rank=$SLURM_PROCID \
    train_sam_model.py $CONFIG_PATH --path=$LOG_PATH --resume

                                                                    