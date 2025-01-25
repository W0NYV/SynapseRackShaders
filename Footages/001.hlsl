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

struct LogPolar
{
    float2 id;
    float2 uv;
};

LogPolar logPolarPolka(float2 p, float s)
{
    p = float2(log(length(p)), atan2(p.y, p.x));

    p = mul(p, rot(acos(-1.0)/2.0));

    p *= s/acos(-1.0);

    LogPolar lp;
    
    p.y += t;
    
    lp.id = floor(p);    
    lp.uv = frac(p);

    return lp;
}

float sdAsteroid(float2 p, float a)
{
    float2 q = abs(p);
    return pow(q.x, 2.0/3.0) + pow(q.y, 2.0/3.0) - pow(a, 2.0/3.0);
}

float sdSquare(float2 p, float a)
{
    return abs(p.x+p.y) + abs(p.x-p.y) - a;
}

float mod(float x, float y) {
    return x - y * floor(x / y);
}

float4 Frag(VsOutput input) : SV_TARGET
{
    float2 p = (input.uv * 2 - 1) * 0.5;
    p.x *= resolution.x/resolution.y;

    p = mul(p, rot(t*1.0/8.0));

    LogPolar logp = logPolarPolka(p, 11.0);
    logp.uv -= 0.5;
    logp.uv = mul(logp.uv, rot(pow(frac(t / 4.0 + logp.id.x * acos(-1.0)*2.0 + logp.id.y * acos(-1.0)*2.0), 16.0) * acos(-1.0)/2.0));
    float s = max(sdAsteroid(logp.uv, 0.01), -sdAsteroid(logp.uv, 0.65));
    s = smoothstep(0.5, 0.4, s);
    s =  mod(logp.id.x, 2.0) < 1.0 ? s : smoothstep(0.05, 0.045, sdSquare(mul(logp.uv, rot(acos(-1.0)/4.0)), 0.1));
    s *= mod(logp.id.y, 2.0) < 1.0 ? 1.0 : 0.0;

    float3 col = s;
    
    col *= smoothstep(0.01, 0.4, length(p)) * smoothstep(2.2, 0.8, length(p));

    return float4(col,1.0);
}