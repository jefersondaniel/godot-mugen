struct SND_HEADER {
    char signature[12];
    unsigned char verlo3;
    unsigned char verlo2;
    unsigned char verlo1;
    unsigned char verhi;
    uint32_t total_sounds;
    uint32_t subheader_offset;
    char unused[488];
};

struct SND_SUBHEADER {
    uint32_t next;
    uint32_t length;
    uint32_t groupno;
    uint32_t soundno;
};

struct WAV_HEADER {
    uint8_t riff[4]; // RIFF Header Magic header
    uint32_t chunkSize; // RIFF Chunk Size
    uint8_t format[4]; // WAVE header
    uint8_t subchunk1ID[4]; // FMT header
    uint32_t subchunk1Size; // Size of the fmt chunk
    uint16_t audioFormat; // Audio format 1=PCM,6=mulaw,7=alaw,     257=IBM Mu-Law, 258=IBM A-Law, 259=ADPCM
    uint16_t numChannels; // Number of channels 1=Mono 2=Sterio
    uint32_t sampleRate; // Sampling Frequency in Hz
    uint32_t byteRate; // bytes per second
    uint16_t blockAlign; // 2=16-bit mono, 4=16-bit stereo
    uint16_t bitsPerSample; // Number of bits per sample
    uint8_t subchunk2ID[4]; // "data"  string
    uint32_t subchunk2Size; // Sampled data length
};

FileStream &operator>>( FileStream &ds, SND_HEADER &header )
{
    ds.readRawData((char *) &header.signature, 12);
    ds >> header.verlo3;
    ds >> header.verlo2;
    ds >> header.verlo1;
    ds >> header.verhi;
    ds.readRawData((char *) &header.total_sounds, 4);
    ds.readRawData((char *) &header.subheader_offset, 4);
    ds.readRawData((char *) &header.unused, 488);

    return ds;
};

FileStream &operator>>( FileStream &ds, SND_SUBHEADER &subheader )
{
    ds.readRawData((char *) &subheader.next, 4);
    ds.readRawData((char *) &subheader.length, 4);
    ds.readRawData((char *) &subheader.groupno, 4);
    ds.readRawData((char *) &subheader.soundno, 4);

    return ds;
};

ByteArrayStream &operator>>(ByteArrayStream &ds, WAV_HEADER &header) {
    ds.get_data(header.riff, 4); // uint8_t riff[4];
    ds >> header.chunkSize; // uint32_t chunkSize;
    ds.get_data(header.format, 4); // uint8_t format[4];
    ds.get_data(header.subchunk1ID, 4); // uint8_t subchunk1ID[4];
    ds >> header.subchunk1Size; // uint32_t subchunk1Size;
    ds >> header.audioFormat; // uint16_t audioFormat;
    ds >> header.numChannels; // uint16_t numChannels;
    ds >> header.sampleRate; // uint32_t sampleRate;
    ds >> header.byteRate; // uint32_t byteRate;
    ds >> header.blockAlign; // uint16_t blockAlign;
    ds >> header.bitsPerSample; // uint16_t bitsPerSample;
    ds.get_data(header.subchunk2ID, 4); // uint8_t subchunk2ID[4];
    ds >> header.subchunk2Size; // uint32_t subchunk2Size;

    return ds;
};
