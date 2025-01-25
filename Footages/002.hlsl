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

float4 Frag(VsOutput input) : SV_TARGET
{

    float2 p = (input.uv * 2 - 1) * 0.5;
    p.x *= resolution.x/resolution.y;

    float r = Pcg3d01(float3(floor(t), 743.52, 6745.352)).r;
    float r2 = Pcg3d01(float3(floor(t*4.0), 4523.342, 946.531)).r;

    p = mul(p, rot(r * acos(-1.0)*2.0));
    p.x *= 2.0;
    
    float3 col = sin(2.0*p.y+acos(-1.0)/2.0);
    
    col = pow(col, 0.4545);
    
    col *= clamp(abs(sin(p.x*5.0*(r2*2.0))), 0.1, 1.0);
    col *= clamp(abs(sin(p.y*150.0 + t * 2.0)), 0.3, 1.0);
    
    col = float3(pow(col.r, 3.0/2.0), pow(col.g, 5.0/4.0), pow(col.b, 3.0/2.0));

    return float4(col, 1.0);
}