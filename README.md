# Garmin 3D Benchmark

Source code of the Garmin Connect IQ 3D Benchmark by Tomas Slavicek
Download: https://apps.garmin.com/en-US/apps/c39b8b25-7ac8-4481-b8be-8899ef12facc

3D renderer of the layout
- reads the GameData object (information where are the cubes, what are the parameters of the camera)
- on every frame it gets the position of vertices in 3D, sets up the perspective camera, and calculates the projected positions on the screen
- this algorithm calculates it using the model, view and projection matrices (theory: https://cw.fel.cvut.cz/b182/courses/gvg/start),
  although the calculations are a bit more compact for this specific case (if something in the matrix was 0, we don't calculate it here)
- another document to this topic (in Czech language): https://cw.fel.cvut.cz/old/_media/courses/b0b39pgr/05-transformace-2.pdf

Author: Tomas Slavicek, support @ tomasslavicek.cz

More apps and games from me: https://apps.garmin.com/en-US/developer/01782aec-91a1-4db6-bf8e-70e8b6da47e0/apps

You can send me a donation on https://myday24.com/ if you like my work.