---
title: AI/LLM Engineer Roadmap
type: roadmap
created: 2026-04-28
updated: 2026-04-28
source_files: []
tags: [roadmap, learning-path]
---

# AI/LLM Engineer Roadmap

> Human-owned file. Do not modify. Gap-agent reads this to score knowledge gaps.
> Update this file manually as your learning goals evolve.

---

## 1. Foundations

### 1.1 Mathematics
- Linear algebra — vectors, matrices, dot products, eigenvalues
- Calculus — gradients, chain rule, partial derivatives
- Probability & statistics — distributions, Bayes, MLE, entropy
- Information theory — KL divergence, cross-entropy, mutual information

### 1.2 Machine Learning Core
- Supervised learning — loss functions, optimisation, regularisation
- Gradient descent — SGD, Adam, learning rate schedules
- Overfitting & generalisation — bias-variance tradeoff, dropout, weight decay
- Evaluation — metrics, train/val/test splits, cross-validation

### 1.3 Deep Learning Fundamentals
- Feedforward networks — layers, activations, backpropagation
- Convolutional networks — kernels, pooling, receptive fields
- Recurrent networks — RNN, LSTM, vanishing gradients
- Embeddings — word2vec, GloVe, representation learning

---

## 2. Transformer Architecture

### 2.1 Core Mechanism
- Self-attention — query, key, value, scaled dot-product
- Multi-head attention — parallel heads, concatenation
- Positional encoding — sinusoidal, learned, RoPE, ALiBi
- Feed-forward sublayer — MLP within transformer block
- Layer normalisation — pre-norm vs post-norm

### 2.2 Architecture Variants
- Encoder-only — BERT, RoBERTa, DeBERTa
- Decoder-only — GPT family, LLaMA, Mistral
- Encoder-decoder — T5, BART, mT5
- Mixture of Experts (MoE) — sparse gating, expert routing

### 2.3 Scaling
- Scaling laws — Chinchilla, compute-optimal training
- Emergent abilities — in-context learning, chain-of-thought
- Long context — sliding window, sparse attention, ring attention

---

## 3. Pretraining

### 3.1 Data
- Pretraining corpora — Common Crawl, The Pile, DCLM
- Data quality filtering — deduplication, perplexity filtering, URL rules
- Tokenisation — BPE, WordPiece, SentencePiece, tiktoken

### 3.2 Training Infrastructure
- Mixed precision training — FP16, BF16, loss scaling
- Distributed training — data parallelism, tensor parallelism, pipeline parallelism
- Gradient checkpointing — memory vs compute tradeoff
- FlashAttention — IO-aware exact attention

### 3.3 Optimisation
- AdamW — decoupled weight decay
- Learning rate warmup and cosine decay
- Gradient clipping
- Batch size scaling

---

## 4. Post-Training

### 4.1 Supervised Fine-Tuning (SFT)
- Instruction tuning — FLAN, Alpaca, ShareGPT formats
- Chat templates — ChatML, Llama format, system prompts
- Data quality vs quantity tradeoffs

### 4.2 Alignment
- RLHF — reward model training, PPO for LLMs
- DPO — direct preference optimisation, Bradley-Terry model
- Constitutional AI — critique and revision
- Rejection sampling fine-tuning (RFT)

### 4.3 Parameter-Efficient Fine-Tuning (PEFT)
- LoRA — low-rank adaptation, rank selection
- QLoRA — quantised base model + LoRA
- Prefix tuning, prompt tuning, adapters
- Merging — TIES, DARE, model soup

---

## 5. Inference & Serving

### 5.1 Efficient Inference
- KV cache — memory layout, eviction strategies
- Speculative decoding — draft model, acceptance rate
- Continuous batching — iteration-level scheduling
- PagedAttention — virtual KV cache blocks

### 5.2 Quantisation
- Post-training quantisation — INT8, INT4, GPTQ, AWQ
- Quantisation-aware training
- KV cache quantisation

### 5.3 Serving Systems
- vLLM — architecture, throughput benchmarks
- TGI (Text Generation Inference) — Hugging Face serving
- TensorRT-LLM — NVIDIA optimised inference
- Ollama — local serving

### 5.4 Sampling
- Temperature, top-k, top-p (nucleus), min-p
- Repetition penalty, frequency penalty
- Beam search vs greedy vs sampling

---

## 6. Evaluation

### 6.1 Benchmarks
- MMLU, HellaSwag, ARC — knowledge and reasoning
- HumanEval, MBPP — code generation
- MT-Bench, AlpacaEval, Arena — instruction following
- MATH, GSM8K — mathematical reasoning

### 6.2 Evaluation Methodology
- LLM-as-judge — bias, position effects, calibration
- Human evaluation — annotation guidelines, inter-rater agreement
- Contamination — data leakage detection

### 6.3 Safety Evaluation
- Harmlessness benchmarks — TruthfulQA, BBQ
- Red teaming — adversarial prompting, jailbreaks
- Refusal calibration — over-refusal vs under-refusal

---

## 7. Retrieval-Augmented Generation (RAG)

### 7.1 Core RAG
- Chunking strategies — fixed, semantic, hierarchical
- Dense retrieval — bi-encoder, FAISS, vector stores
- Sparse retrieval — BM25, keyword search
- Hybrid retrieval — RRF, re-ranking

### 7.2 Advanced RAG
- HyDE — hypothetical document embeddings
- Multi-hop retrieval — iterative retrieval chains
- Contextual compression — extractive summarisation of retrieved chunks
- RAG vs long context — when to use which

### 7.3 Embedding Models
- Sentence transformers — bi-encoder training, contrastive loss
- Late interaction — ColBERT
- Matryoshka embeddings — MRL training

---

## 8. Agents & Tool Use

### 8.1 Prompting Patterns
- Chain-of-thought (CoT) — zero-shot, few-shot
- ReAct — reasoning + acting
- Tree of Thoughts — branching search
- Scratchpad and extended thinking

### 8.2 Tool Use
- Function calling — schema, parallel calls, streaming
- Code interpreter — sandboxed execution
- Browser use — DOM interaction, web scraping

### 8.3 Multi-Agent Systems
- Agent orchestration — planner, executor, critic
- Memory systems — short-term, long-term, episodic
- MCP (Model Context Protocol) — tool server standard

---

## 9. Multimodal

### 9.1 Vision-Language Models
- Image encoding — ViT, CLIP, SigLIP
- Connector architectures — MLP projector, cross-attention, Q-Former
- Visual instruction tuning — LLaVA, InternVL

### 9.2 Audio
- Speech-to-text — Whisper architecture and training
- Text-to-speech — VITS, StyleTTS2
- Audio LLMs — speech tokens, interleaved generation

### 9.3 Other Modalities
- Video — frame sampling, temporal attention
- Code — syntax-aware tokenisation, repo-level context

---

## 10. Safety & Alignment Theory

### 10.1 AI Safety Concepts
- Alignment problem — inner vs outer alignment
- Reward hacking and Goodhart's law
- Corrigibility — shutdown problem, interruptibility

### 10.2 Interpretability
- Mechanistic interpretability — circuits, superposition
- Activation patching — causal tracing
- Sparse autoencoders (SAE) — feature decomposition

### 10.3 Governance & Policy
- AI policy landscape — EU AI Act, executive orders
- Model cards and datasheets
- Responsible scaling policies

---

## Progress Tracking

| section | topics | covered | partial | missing |
|---|---|---|---|---|
| 1. Foundations | 12 | 0 | 0 | 12 |
| 2. Transformer Architecture | 13 | 0 | 0 | 13 |
| 3. Pretraining | 12 | 0 | 0 | 12 |
| 4. Post-Training | 12 | 0 | 0 | 12 |
| 5. Inference & Serving | 14 | 0 | 0 | 14 |
| 6. Evaluation | 9 | 0 | 0 | 9 |
| 7. RAG | 11 | 0 | 0 | 11 |
| 8. Agents & Tool Use | 9 | 0 | 0 | 9 |
| 9. Multimodal | 9 | 0 | 0 | 9 |
| 10. Safety & Alignment Theory | 9 | 0 | 0 | 9 |
| **Total** | **110** | **0** | **0** | **110** |

> Update this table manually or ask gap-agent to refresh it after /gap-check.
