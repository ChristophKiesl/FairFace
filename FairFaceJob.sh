#!/bin/bash
#SBATCH --job-name=FairFaceJob               # Name des Jobs
#SBATCH --output=job.FairFaceJob.out             # Standard-Ausgabe ( %j = JobID )
#SBATCH --error=job.FairFaceJob.err              # Fehler-Ausgabe
#SBATCH --partition=cpu                 # Partition / queue (z.B. cpu, gpu, dev)
#SBATCH --nodes=1                       # Anzahl Knoten
#SBATCH --ntasks=1                      # Gesamtzahl Tasks (Prozesse)
#SBATCH --cpus-per-task=4               # Threads pro Task (OpenMP etc.)
#SBATCH --time=72:00:00                 # Walltime HH:MM:SS
#SBATCH --mem=16GB                        # Arbeitsspeicher gesamt oder pro Node

# --- Job-Befehle ---
# ins Verzeichnis wechseln, von dem du sbatch aufrufst
cd $SLURM_SUBMIT_DIR

# virtuelle Umgebung aktivieren
source venv/bin/activate

# Python-Skript ausführen
cd FairFace
python predict.py --csv input.csv
