#!/usr/bin/env python3
"""
Plot ZRAM compression ratio timeseries data.

Usage: python plot_zram_timeseries.py <csv_file> [output_file]
"""

import sys
import pandas as pd
import matplotlib.pyplot as plt
import argparse
from pathlib import Path

def plot_compression_ratio(csv_file, output_file=None, title=None):
    """
    Plot compression ratio over time from zram timeseries CSV.
    
    Args:
        csv_file: Path to the CSV file with timeseries data
        output_file: Optional path to save the plot (PNG format)
        title: Optional custom title for the plot
    """
    
    try:
        # Read the CSV file
        df = pd.read_csv(csv_file)
        
        # Validate required columns
        required_cols = ['TimePoint', 'DataBytes', 'ComprBytes', 'Ratio']
        if not all(col in df.columns for col in required_cols):
            print(f"Error: CSV must contain columns: {required_cols}")
            print(f"Found columns: {list(df.columns)}")
            return False
            
        # Create the plot
        plt.figure(figsize=(12, 12))
        
        # Main plot: Compression ratio over time
        plt.subplot(3, 1, 1)
        plt.plot(df['TimePoint'], df['Ratio'], linewidth=1.5, color='blue', alpha=0.8)
        plt.xlabel('Time Point (seconds)')
        plt.ylabel('Compression Ratio')
        plt.title(title or f'Compression Ratio Over Time\n{Path(csv_file).name}')
        plt.grid(True, alpha=0.3)
        
        # Add statistics to the plot
        mean_ratio = df['Ratio'].mean()
        std_ratio = df['Ratio'].std()
        plt.axhline(y=mean_ratio, color='red', linestyle='--', alpha=0.7, 
                   label=f'Mean: {mean_ratio:.3f}')
        plt.axhline(y=mean_ratio + std_ratio, color='orange', linestyle=':', alpha=0.7,
                   label=f'Mean ± σ: {std_ratio:.3f}')
        plt.axhline(y=mean_ratio - std_ratio, color='orange', linestyle=':', alpha=0.7)
        plt.legend()
        
        # Secondary plot: Data and compressed sizes over time
        plt.subplot(3, 1, 2)
        plt.plot(df['TimePoint'], df['DataBytes'] / 1e9, linewidth=1.5, 
                color='green', alpha=0.8, label='Uncompressed Data (GB)')
        plt.plot(df['TimePoint'], df['ComprBytes'] / 1e9, linewidth=1.5, 
                color='red', alpha=0.8, label='Compressed Data (GB)')
        plt.xlabel('Time Point (seconds)')
        plt.ylabel('Size (GB)')
        plt.title('Data Sizes Over Time')
        plt.grid(True, alpha=0.3)
        plt.legend()
        
        # Third plot: Focused compression ratio (restricted y-axis, filtering out early erratic data)
        plt.subplot(3, 1, 3)
        
        # Filter out early erratic data when heap is small
        # Consider data stable when compressed size > 1GB or after 10% of total time
        min_stable_size = 1e9  # 1GB compressed
        min_stable_time = len(df) * 0.1  # 10% of total time points
        
        stable_mask = (df['ComprBytes'] > min_stable_size) | (df['TimePoint'] > min_stable_time)
        df_stable = df[stable_mask].copy() if stable_mask.any() else df.copy()
        
        # Calculate statistics for stable data
        mean_ratio_stable = df_stable['Ratio'].mean()
        std_ratio_stable = df_stable['Ratio'].std()
        
        # Plot stable data only
        plt.plot(df_stable['TimePoint'], df_stable['Ratio'], linewidth=1.5, color='darkgreen', alpha=0.8)
        
        # Set y-axis to mean ± 2*std for better focus
        y_margin = 2 * std_ratio_stable
        y_min = max(0, mean_ratio_stable - y_margin)
        y_max = mean_ratio_stable + y_margin
        plt.ylim(y_min, y_max)
        
        plt.xlabel('Time Point (seconds)')
        plt.ylabel('Compression Ratio')
        plt.title(f'Compression Ratio Over Time (Focused Range: {y_min:.2f} - {y_max:.2f}, Stable Data Only)')
        plt.grid(True, alpha=0.3)
        
        # Add statistics lines for stable data
        plt.axhline(y=mean_ratio_stable, color='red', linestyle='--', alpha=0.7, 
                   label=f'Stable Mean: {mean_ratio_stable:.3f}')
        plt.axhline(y=mean_ratio_stable + std_ratio_stable, color='orange', linestyle=':', alpha=0.7,
                   label=f'Stable σ: {std_ratio_stable:.3f}')
        plt.axhline(y=mean_ratio_stable - std_ratio_stable, color='orange', linestyle=':', alpha=0.7)
        plt.legend()
        
        plt.tight_layout()
        
        # Save or show the plot
        if output_file:
            plt.savefig(output_file, dpi=300, bbox_inches='tight')
            print(f"Plot saved to: {output_file}")
        else:
            plt.show()
            
        # Print summary statistics
        print(f"\n=== Summary Statistics ===")
        print(f"Total time points: {len(df)}")
        print(f"Duration: {df['TimePoint'].max()} seconds")
        print(f"Mean compression ratio: {mean_ratio:.3f}")
        print(f"Std compression ratio: {std_ratio:.3f}")
        print(f"Min compression ratio: {df['Ratio'].min():.3f}")
        print(f"Max compression ratio: {df['Ratio'].max():.3f}")
        print(f"Final data size: {df['DataBytes'].iloc[-1] / 1e9:.2f} GB")
        print(f"Final compressed size: {df['ComprBytes'].iloc[-1] / 1e9:.2f} GB")
        
        return True
        
    except FileNotFoundError:
        print(f"Error: File not found: {csv_file}")
        return False
    except pd.errors.EmptyDataError:
        print(f"Error: Empty CSV file: {csv_file}")
        return False
    except Exception as e:
        print(f"Error processing file: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(description='Plot ZRAM compression ratio timeseries')
    parser.add_argument('csv_file', help='Path to the timeseries CSV file')
    parser.add_argument('-o', '--output', help='Output file path (PNG format)')
    parser.add_argument('-t', '--title', help='Custom title for the plot')
    
    args = parser.parse_args()
    
    # Check if input file exists
    if not Path(args.csv_file).exists():
        print(f"Error: Input file does not exist: {args.csv_file}")
        sys.exit(1)
    
    # Generate default output filename if not provided
    output_file = args.output
    if not output_file and len(sys.argv) > 1:
        # Auto-generate output filename based on input
        input_path = Path(args.csv_file)
        output_file = input_path.parent / f"{input_path.stem}_plot.png"
    
    success = plot_compression_ratio(args.csv_file, output_file, args.title)
    
    if not success:
        sys.exit(1)

if __name__ == "__main__":
    main()
