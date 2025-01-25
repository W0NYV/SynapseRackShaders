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


float4 Frag(VsOutput input) : SV_TARGET
{
    float2 uv = (input.uv * 2 - 1) * 0.5;
    return float4(uv.x,uv.y,0.0, 1.0);
}