struct FNT_HEADER {
    char signature[12];
    unsigned char verlo3;
    unsigned char verlo2;
    unsigned char verlo1;
    unsigned char verhi;
    uint32_t pcx_offset;
    uint32_t pcx_size;
    uint32_t text_offset;
    uint32_t text_size;
    char unused[40];
};

FileStream &operator>>( FileStream &ds, FNT_HEADER &header )
{
    ds.readRawData((char *) &header.signature, 12);
    ds >> header.verlo3;
    ds >> header.verlo2;
    ds >> header.verlo1;
    ds >> header.verhi;
    ds.readRawData((char *) &header.pcx_offset, 4);
    ds.readRawData((char *) &header.pcx_size, 4);
    ds.readRawData((char *) &header.text_offset, 4);
    ds.readRawData((char *) &header.text_size, 4);
    ds.readRawData((char *) &header.unused, 40);

    return ds;
};
