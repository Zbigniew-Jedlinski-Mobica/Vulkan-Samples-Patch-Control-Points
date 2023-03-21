/* Copyright (c) 2023, Mobica Limited
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Licensed under the Apache License, Version 2.0 the "License";
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#version 450

layout(binding = 0) uniform UBO
{
	mat4  projection;
	mat4  view;
}
ubo;

layout(binding = 1) uniform UBOTessellation
{
	float tessellationFactor;
}
ubo_tessellation;

layout(vertices = 3) out;

layout(location = 0) in vec3 inPos[];
layout(location = 1) in vec3 inNormal[];

layout(location = 0) out vec3 outPos[3];
layout(location = 1) out vec3 outNormal[3];

float GetTessLevel(vec4 p0, vec4 p1)
{
	float tesselationValue = 0.0f;
	float midDistance = 1.6f;
	float shortDistance = 1.0f;

	// Calculate edge mid point
	vec4 midPoint = 0.5f * (p0 + p1);
	
	// Calculate vector from camera to mid point
	vec4 vCam = ubo.view * midPoint;

	// Calculate vector for camera projection
	vec4 vCamView = ubo.projection * vCam;

	// Calculate the vector length
	float AvgDistance = length(vCamView);

	// Adjusting the size of the tessellation depending on the length of the vector
	if (AvgDistance >= midDistance)
	{
		tesselationValue = 1.0f;
	}
	else if (AvgDistance >= shortDistance && AvgDistance < midDistance)
	{
		tesselationValue = ubo_tessellation.tessellationFactor * 0.4;
	}
	else
	{
		tesselationValue = ubo_tessellation.tessellationFactor;
	}

	return tesselationValue;
}

void main()
{
	if (ubo_tessellation.tessellationFactor > 0.0)
	{
		gl_TessLevelOuter[0] = GetTessLevel(gl_in[2].gl_Position, gl_in[0].gl_Position);
		gl_TessLevelOuter[1] = GetTessLevel(gl_in[0].gl_Position, gl_in[1].gl_Position);
		gl_TessLevelOuter[2] = GetTessLevel(gl_in[1].gl_Position, gl_in[2].gl_Position);
		gl_TessLevelInner[0] = mix(gl_TessLevelOuter[0], gl_TessLevelOuter[2], 0.5);
	}
	else
	{
		gl_TessLevelOuter[0] = 1;
		gl_TessLevelOuter[1] = 1;
		gl_TessLevelOuter[2] = 1;
		gl_TessLevelInner[0] = 1;
	}

	gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;
	outNormal[gl_InvocationID]          = inNormal[gl_InvocationID];
	outPos[gl_InvocationID]             = inPos[gl_InvocationID];
}
