using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof (MeshFilter))]
[RequireComponent(typeof (MeshRenderer))]
public class BadMinecraft : MonoBehaviour
{
    Mesh mesh;

    void Start()
    {
        MakeCube();
    }

    void MakeCube()
    {
        Vector3[] c =
        {
            new Vector3(0, 0, 0),
            new Vector3(1, 0, 0),
            new Vector3(1, 1, 0),
            new Vector3(0, 1, 0),
            new Vector3(0, 1, 1),
            new Vector3(1, 1, 1),
            new Vector3(1, 0, 1),
            new Vector3(0, 0, 1)

        };

        Vector3[] vertices =
        {
            // 0 1 2 3
            c[0], c[1], c[2], c[3],
            // 4 5 6 7
            c[3], c[2], c[5], c[4],
            // 8 9 10 12
            c[1], c[6], c[5], c[2],
            // 12 13 14 15
            c[0], c[3], c[4], c[7],
            // 16 17 18 19
            c[7], c[4], c[5], c[6],
            // 20 21 22 23
            c[0], c[1], c[6], c[7]

        };
        
        Vector3 up = Vector3.up;
        Vector3 down = Vector3.down;
        Vector3 front = Vector3.forward;
        Vector3 back = Vector3.back;
        Vector3 left = Vector3.left;
        Vector3 right = Vector3.right;
        
        Vector3[] normals =
        {
            // 0 1 2 3
            down, down, down, down,
            // 4 5 6 7
            front, front, front, front,
            // 8 9 10 11
            right, right, right, right,
            // 12 13 14 15
            back, back, back, back,
            // 16 17 18 19
            left, left, left, left,
            // 20 21 22 23
            up, up, up, up
        };
        
Vector2[] uv =
        {// 前面
            new(0.0f, 0.0f), new(0.5f, 0.0f), new(0.0f, 0.5f), new(0.5f, 0.5f),

// 后面
            new(0.0f, 0.5f), new(0.5f, 0.5f), new(0.0f, 1.0f), new(0.5f, 1.0f),

// 左面
            new(0.5f, 0.0f), new(1.0f, 0.0f), new(0.5f, 0.5f), new(1.0f, 0.5f),

// 右面
            new(0.0f, 0.5f), new(0.5f, 0.5f), new(0.0f, 1.0f), new(0.5f, 1.0f),

// 上面
            new(0.0f, 0.0f), new(0.5f, 0.0f), new(0.0f, 0.5f), new(0.5f, 0.5f),

// 下面
            new(0.5f, 0.0f), new(1.0f, 0.0f), new(0.5f, 0.5f), new(1.0f, 0.5f)
        };
        
        int[] triangles = 
        {
            // 前面
            0, 2, 1,   0, 3, 2,

            // 后面
            4, 6, 5,   4, 7, 6,

            // 左面
            8, 10, 9,  8, 11, 10,

            // 右面
            12, 14, 13, 12, 15, 14,

            // 上面
            16, 18, 17, 16, 19, 18,

            // 下面
            20, 22, 21, 20, 23, 22
        };

        mesh = GetComponent<MeshFilter>().mesh;
        mesh.Clear();
        
        mesh.vertices = vertices;
        mesh.uv = uv;
        mesh.triangles = triangles;
        mesh.normals = normals;

    }
}
