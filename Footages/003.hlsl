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

float2 hash22(float2 p)
{
    p = mul(p, float2x2(127.1,311.7,269.5,183.3));
	p = -1.0 + 2.0 * frac(sin(p)*43758.5453123);
	return sin(p*6.283 + t);
}

float perlin_noise(float2 p)
{
	float2 pi = floor(p);
    float2 pf = p-pi;
    
    float2 w = pf*pf*(3.-2.*pf);
    
    float f00 = dot(hash22(pi+float2(.0,.0)),pf-float2(.0,.0));
    float f01 = dot(hash22(pi+float2(.0,1.)),pf-float2(.0,1.));
    float f10 = dot(hash22(pi+float2(1.0,0.)),pf-float2(1.0,0.));
    float f11 = dot(hash22(pi+float2(1.0,1.)),pf-float2(1.0,1.));
    
    float xm1 = lerp(f00,f10,w.x);
    float xm2 = lerp(f01,f11,w.x);
    
    float ym = lerp(xm1,xm2,w.y); 
    return ym;
   
}

float4 Frag(VsOutput input) : SV_TARGET
{
    float2 p = (input.uv * 2 - 1) * 0.5;
    p.x *= resolution.x/resolution.y;

    p *= 2.0;

    float result;
    float mask = 1.0;
    
    p.y += 0.8;
    
    for (float n = 0.0; n < 16.0; n += 1.0)
    {
        float2 pp = p;
        
        float r = Pcg3d01(float3(n, 32.41, 134.41)).r * 100.0;
        float noise = perlin_noise(float2(p.x*2.0 + r + t/2.0, t + perlin_noise(float2(p.x*0.25, t*2.0)))) * 0.5 + 0.5;
        pp.y -= 2.0 * pow(noise, 5.0) * smoothstep(0.0, 1.0, pow(1.0 / length(pp.x), 5.0));

        float l = fmod(n + floor(t), 5.0)>0.0 ? step(length(pp.y), 0.01) : step(length(pp.y), 0.05);

        result += l * mask;

        mask *= step(length(pp.y - 1.0), 1.0);
        p.y -= 0.1;
    }

    float3 col = result;

    return float4(col, 1.0);
}