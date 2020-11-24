# libopus statically linked for Go

libopus from https://opus-codec.org/downloads/ (BSD licensed, see https://opus-codec.org/license/ for details)

Extra go code from https://github.com/hraban/opus (MIT licensed)

[![Test](https://github.com/KarpelesLab/static-opus/workflows/Test/badge.svg)](https://github.com/KarpelesLab/static-opus/actions?query=workflow%3ATest)

## Go wrapper for Opus

This package provides Go bindings for the xiph.org C library libopus.

The C library and docs are hosted at https://opus-codec.org/. This package
just handles the wrapping in Go and includes a copy of the said library, but
is unaffiliated with xiph.org.

## Details

This wrapper provides a Go translation layer for two elements from the
xiph.org opus libs:

* encoders
* decoders

### Import

```go
import "github.com/KarpelesLab/static-opus/opus"
```

### Encoding

To encode raw audio to the Opus format, create an encoder first:

```go
const sampleRate = 48000
const channels = 1 // mono; 2 for stereo

enc, err := opus.NewEncoder(sampleRate, channels, opus.AppVoIP)
if err != nil {
    ...
}
```

Then pass it some raw PCM data to encode.

Make sure that the raw PCM data you want to encode has a legal Opus frame size.
This means it must be exactly 2.5, 5, 10, 20, 40 or 60 ms long. The number of
bytes this corresponds to depends on the sample rate (see the [libopus
documentation](https://www.opus-codec.org/docs/opus_api-1.1.3/group__opus__encoder.html)).

```go
var pcm []int16 = ... // obtain your raw PCM data somewhere
const bufferSize = 1000 // choose any buffer size you like. 1k is plenty.

// Check the frame size. You don't need to do this if you trust your input.
frameSize := len(pcm) // must be interleaved if stereo
frameSizeMs := float32(frameSize) / channels * 1000 / sampleRate
switch frameSizeMs {
case 2.5, 5, 10, 20, 40, 60:
    // Good.
default:
    return fmt.Errorf("Illegal frame size: %d bytes (%f ms)", frameSize, frameSizeMs)
}

data := make([]byte, bufferSize)
n, err := enc.Encode(pcm, data)
if err != nil {
    ...
}
data = data[:n] // only the first N bytes are opus data. Just like io.Reader.
```

Note that you must choose a target buffer size, and this buffer size will affect
the encoding process:

> Size of the allocated memory for the output payload. This may be used to
> impose an upper limit on the instant bitrate, but should not be used as the
> only bitrate control. Use `OPUS_SET_BITRATE` to control the bitrate.

-- https://opus-codec.org/docs/opus_api-1.1.3/group__opus__encoder.html

### Decoding

To decode opus data to raw PCM format, first create a decoder:

```go
dec, err := opus.NewDecoder(sampleRate, channels)
if err != nil {
    ...
}
```

Now pass it the opus bytes, and a buffer to store the PCM sound in:

```go
var frameSizeMs float32 = ...  // if you don't know, go with 60 ms.
frameSize := channels * frameSizeMs * sampleRate / 1000
pcm := make([]int16, int(frameSize))
n, err := dec.Decode(data, pcm)
if err != nil {
    ...
}

// To get all samples (interleaved if multiple channels):
pcm = pcm[:n*channels] // only necessary if you didn't know the right frame size

// or access sample per sample, directly:
for i := 0; i < n; i++ {
    ch1 := pcm[i*channels+0]
    // For stereo output: copy ch1 into ch2 in mono mode, or deinterleave stereo
    ch2 := pcm[(i*channels)+(channels-1)]
}
```

To handle packet loss from an unreliable network, see the
[DecodePLC](https://godoc.org/gopkg.in/hraban/opus.v2#Decoder.DecodePLC) and
[DecodeFEC](https://godoc.org/gopkg.in/hraban/opus.v2#Decoder.DecodeFEC)
options.

### API Docs

Go wrapper API reference:
https://godoc.org/github.com/KarpelesLab/static-opus

Full libopus C API reference:
https://www.opus-codec.org/docs/opus_api-1.1.3/

For more examples, see the `_test.go` files.
