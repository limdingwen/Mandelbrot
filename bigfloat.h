enum sign
{
    SIGN_NEG,
    SIGN_ZERO,
    SIGN_POS
};

struct __attribute__ ((packed)) fp256
{
    enum sign sign;
    CL_UINT man[8];
};

struct __attribute__ ((packed)) fp512
{
    enum sign sign;
    CL_UINT man[16];
};

struct fp256 fp_uadd256(struct fp256 a, struct fp256 b)
{
    struct fp256 c;
    char carry = 0;
    for (int i = 7; i >= 0; i--)
    {
        CL_ULONG temp = (CL_ULONG)a.man[i] + (CL_ULONG)b.man[i] + (CL_ULONG)carry;
        carry = (char)(temp >> 32); // Note that the highest 31 bits of temp are all 0.
        c.man[i] = (CL_UINT)temp;
    }
    return c;
}

struct fp256 fp_usub256(struct fp256 a, struct fp256 b)
{
    struct fp256 c;
    char carry = 0;
    for (int i = 7; i >= 0; i--)
    {
        CL_ULONG temp = (CL_ULONG)a.man[i] - (CL_ULONG)b.man[i] - (CL_ULONG)carry;
        carry = (char)(temp >> 63); // Check if wrapped around.
        c.man[i] = (CL_UINT)temp;
    }
    return c;
}

struct fp512 fp_uadd512(struct fp512 a, struct fp512 b)
{
    struct fp512 c;
    char carry = 0;
    for (int i = 15; i >= 0; i--)
    {
        CL_ULONG temp = (CL_ULONG)a.man[i] + (CL_ULONG)b.man[i] + (CL_ULONG)carry;
        carry = (char)(temp >> 32); // Note that the highest 31 bits of temp are all 0.
        c.man[i] = (CL_UINT)temp;
    }
    return c;
}

enum cmp
{
    CMP_SAME,
    CMP_A_BIG,
    CMP_B_BIG
};

enum cmp fp_ucmp256(struct fp256 a, struct fp256 b)
{
    struct fp256 c = fp_usub256(a, b);
    bool is_negative = (c.man[0] >> 31) == 1;
    if (is_negative)
        return CMP_B_BIG;
    else
    {

// Here, we check if the difference is 0. If so, then both a and b are the same,
// but if not, then the difference must be positive, and thus a > b.

        for (int i = 0; i < 8; i++)
            if (c.man[i] != 0)
                return CMP_A_BIG;
        return CMP_SAME;
    }
}

struct fp256 fp_sadd256(struct fp256 a, struct fp256 b)
{
    if (a.sign == SIGN_ZERO && b.sign == SIGN_ZERO)
        return a;
    if (b.sign == SIGN_ZERO)
        return a;
    if (a.sign == SIGN_ZERO)
        return b;
    if ((a.sign == SIGN_POS && b.sign == SIGN_POS) ||
        (a.sign == SIGN_NEG && b.sign == SIGN_NEG))
    {
        struct fp256 c = fp_uadd256(a, b);
        c.sign = a.sign;
        return c;
    }

    //assert((a.sign == SIGN_POS && b.sign == SIGN_NEG) ||
    //       (a.sign == SIGN_NEG && b.sign == SIGN_POS));

    enum cmp cmp = fp_ucmp256(a, b);
    if (cmp == CMP_SAME)
        return (struct fp256) { SIGN_ZERO, {0} };
    
    if (a.sign == SIGN_POS && b.sign == SIGN_NEG)
    {
        if (cmp == CMP_A_BIG)
        {
            struct fp256 c = fp_usub256(a, b);
            c.sign = SIGN_POS;
            return c;
        }
        else
        {
            struct fp256 c = fp_usub256(b, a);
            c.sign = SIGN_NEG;
            return c;
        }
    }
    else
    {
        if (cmp == CMP_A_BIG)
        {
            struct fp256 c = fp_usub256(a, b);
            c.sign = SIGN_NEG;
            return c;
        }
        else
        {
            struct fp256 c = fp_usub256(b, a);
            c.sign = SIGN_POS;
            return c;
        }
    }
}

struct fp256 fp_sinv256(struct fp256 a)
{
    if (a.sign == SIGN_POS) a.sign = SIGN_NEG;
    else if (a.sign == SIGN_NEG) a.sign = SIGN_POS;
    return a;
}

struct fp256 fp_ssub256(struct fp256 a, struct fp256 b)
{
    return fp_sadd256(a, fp_sinv256(b));
}

struct fp256 fp_smul256(struct fp256 a, struct fp256 b)
{
    if (a.sign == SIGN_ZERO || b.sign == SIGN_ZERO)
        return (struct fp256) { SIGN_ZERO, {0} };

    enum sign sign;
    if (a.sign == SIGN_NEG && b.sign == SIGN_NEG)
        sign = SIGN_POS;
    else if (a.sign == SIGN_NEG || b.sign == SIGN_NEG)
        sign = SIGN_NEG;
    else
        sign = SIGN_POS;

    struct fp512 c = {0};
    for (int i = 7; i >= 0; i--) // a
    {
        for (int j = 7; j >= 0; j--) // b
        {
            int low_offset = 15 - (7 - i) - (7 - j);
            //assert(low_offset >= 1);
            int high_offset = low_offset - 1;

            CL_ULONG mult = (CL_ULONG)a.man[i] * (CL_ULONG)b.man[j];
            struct fp512 temp = {0};
            temp.man[low_offset] = (CL_UINT)mult;
            temp.man[high_offset] = mult >> 32;

            c = fp_uadd512(c, temp);
        }
    }

    struct fp256 c256;
    c256.sign = sign;
    for (int i = 1; i <= 8; i++)
        c256.man[i - 1] = c.man[i];

    return c256;
}

struct fp256 fp_ssqr256(struct fp256 a)
{
    return fp_smul256(a, a);
}

struct fp256 fp_asr256(struct fp256 a)
{
    for (int i = 7; i >= 1; i--)
    {
        a.man[i] >>= 1;
        a.man[i] |= (a.man[i - 1] & 0x1) << 31;
    }
    a.man[0] >>= 1;
    return a;
}

struct fp256 int_to_fp256(int a)
{
    if (a == 0)
        return (struct fp256){ SIGN_ZERO, {0} };
    
    struct fp256 b = {0};
    if (a < 0)
    {
        b.sign = SIGN_NEG;
        a = -a;
    }
    else
        b.sign = SIGN_POS;
    
    b.man[0] = (CL_UINT)a;
    return b;
}