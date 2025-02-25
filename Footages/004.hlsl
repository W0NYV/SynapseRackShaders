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
#define delay 0.2

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

float easeOutExpo(float x) {
    return x == 1.0 ? 1.0 : 1.0 - pow(2.0, - 10.0 * x);
}

float sdDiamond(float2 p, float s)
{
    return abs(abs(p.x) + abs(p.y) - s);
}

float sdSquare(float2 p)
{
    return abs(p.x+p.y)+abs(p.x-p.y);
}

float2x2 rot(float r)
{
    return float2x2(cos(r), sin(r), -sin(r), cos(r));
}

float4 Frag(VsOutput input) : SV_TARGET
{
    float2 p = (input.uv * 2 - 1) * 0.5;
    p.x *= resolution.x/resolution.y;

    float ui;

    for (float i = 0.0; i < 8.0; i += 1.0)
    {

        float2 lPastPos = Pcg3d01(float3(floor((t-1.0) / 2.0) - 1.0, 4212.412 + i, 754.763)).xy * 2.0 - 1.0;
        float2 lNextPos = Pcg3d01(float3(floor((t-1.0) / 2.0), 4212.412 + i, 754.763)).xy * 2.0 - 1.0;
        float2 dPastPos = Pcg3d01(float3(floor((t-(1.0+delay)) / 2.0) - 1.0, 4212.412 + i, 754.763)).xy * 2.0 - 1.0;
        float2 dNextPos = Pcg3d01(float3(floor((t-(1.0+delay)) / 2.0), 4212.412 + i, 754.763)).xy * 2.0 - 1.0;

        float2 lp = p;
        float2 dp = p;

        float t2 = fmod(floor(t), 2.0) == 0.0 ? frac(t) : 0.0;
        float t3 = fmod(floor(t - delay), 2.0) == 0.0 ? frac(t - delay) : 0.0;

        lp += lerp(lPastPos, lNextPos, easeOutExpo(t2));
        dp += lerp(dPastPos, dNextPos, easeOutExpo(t3));

        float vLine = step(sdSquare(lp * float2(12.0, 0.1)), 0.085);
        float hLine = step(sdSquare(lp * float2(0.1, 12.0)), 0.085);

        dp = mul(dp, rot(acos(-1.0) / 4.0));

        float outer = step(abs(sdDiamond(dp, 0.25)), 0.0075);
        float inner = step(abs(sdDiamond(dp, 0.05)), 0.005);

        ui += (hLine + vLine + outer + inner);
    }

    float3 col = (float3)ui;

    return float4(col, 1.0);
}