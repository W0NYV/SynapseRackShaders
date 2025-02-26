cbuffer cb : register(b0)
{
    float2 resolution;
    float time;
    float globalBPM;

    float param0;
    float param1;
    float param2;
    float param3;
};

#define t time*globalBPM/60.0

uint3 Pcg3d(uint3 v) 
{
    v = v * 1664525u + 1013904223u;

    v.x += v.y*v.z;
    v.y += v.z*v.x;
    v.z += v.x*v.y;

    v ^= v >> 16u;

    v.x += v.y*v.z;
    v.y += v.z*v.x;
    v.z += v.x*v.y;

    return v;
}

float3 Pcg3d01(uint3 v)
{
    return Pcg3d(v) * 1.0 / float(0xffffffffu);
}


float2x2 rot(float r)
{
    return float2x2(cos(r), sin(r), -sin(r), cos(r));
}

float sdBox(float2 p, float2 b )
{
    float2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

float4 Frag(VsOutput input) : SV_TARGET
{
    float2 p = (input.uv * 2 - 1) * 0.5;
    p.x *= resolution.x/resolution.y;

    float result = 0.0;

    for (float i = 0.0; i < 64.0; i += 1.0)
    {
        float3 rnd = Pcg3d01(float3(525.1452, i, floor(t * 4.0)));

        float2 p2 = p;

        p2.x += 4.0 * (rnd.y - 0.5);
        p2.y += 2.0 * (rnd.z - 0.5);
        p2 = mul(rot(acos(-1.0) * rnd.x), p2);

        result += 0.005 / sdBox(p2, float2(0.75, 0.005));                    
    }

    float3 col = (float3)result * 0.67;

    return float4(col, 1.0);
}