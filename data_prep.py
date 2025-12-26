import numpy as np

# --- 1. Define Input Matrices ---
# We use a simple 4x4 case where the result is easily verified:
# A = Identity Matrix
# B = Matrix of all 3s
# Expected Result: A * B = B (Matrix of all 3s)
N = 4  # Matrix Dimension
DATA_WIDTH = 8 # 8-bit integers

# Matrix A (Input Activations)
A_mat = np.identity(N, dtype=np.uint8) * 1 # Identity Matrix (1s on diagonal)

# Matrix B (Weights)
B_mat = np.full((N, N), 3, dtype=np.uint8) # Matrix of all 3s

# --- 2. Calculate Golden Model (Expected Hardware Output) ---
# Note: Since our Verilog PE has limited precision, we use 16-bit accumulator.
# The result should be cast to 8-bit for final output comparison (if array output is truncated).
C_golden = A_mat.dot(B_mat)

# Print for verification
print("--- Input Matrices (A * B) ---")
print("Matrix A (Activations):\n", A_mat)
print("\nMatrix B (Weights):\n", B_mat)
print("\n--- Expected Output (Golden Model) ---")
print("Matrix C (A * B):\n", C_golden)
print("-" * 30)

# --- 3. Format Data for Verilog RAM ---
# Our RAM address space is sequential (0, 1, 2, 3...)
# We need to map our 2D matrices into this 1D address space.
# Memory Layout: [Weights (B)] followed by [Activations (A)]

# Flatten B (Weights) first (4 rows * 4 cols = 16 words)
# We flatten row-major (B[0,0], B[0,1], ...)
ram_data = B_mat.flatten().tolist()

# Flatten A (Activations) (4 rows * 4 cols = 16 words)
ram_data.extend(A_mat.flatten().tolist())

# Total Memory Words: 32 (16 weights + 16 activations)

# --- 4. Write Data to a Hexadecimal Memory File ---
# This is the file Verilog will $readmemh
HEX_FILE = "memory_init.hex"

print(f"\nWriting {len(ram_data)} words to {HEX_FILE}...")
with open(HEX_FILE, 'w') as f:
    for data in ram_data:
        # Format: 2-digit hex (8-bit data)
        f.write(f"{data:02X}\n")

print(f"Data generation complete. Run Verilog simulation now.")
