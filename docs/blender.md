# Blender
## How to create a new model
- Open blender
- Install [this](https://github.com/noio/Pixel-Unwrapper) add-on. It's extremely helpful with the UV mapping step
- Create new project
- open File -> External Data -> check "Automaticall Pack Resources"
- Save .blender file in appropriate place in project directory
- Create the mesh
    - Going into the ins and outs of blender is beyond the scope of this document, but here are some general tips and guidelines
        - Your bread and butter are going to be the loop tool and manually moving verticies.
        - Try to evoke the idea of something rather than perfectly model its shape. We're aiming for low polygon counts.
            - For reference, the player model has just over 1000 faces total. This should be around the upper bound for characters.
        - The sculpt tools can be nice to even out more organic shapes
        - [watch this](https://youtu.be/7s7uSx18DUc?list=PLjOD0KtDvyJvuH4fkIe7w6cjWVTBHjX-6)
        - *APPLY TRANSFORMS*

- UV Mapping
    - This sucks, is a pain in the butt, and takes forever
    - First mark edges as seams.
      - [watch this](https://youtu.be/qa5TQhoVi7M)
    - Create grid texture
      - Open UV Editor
      - Click "+ New"
      - Name should be something like "nameofyouritem_t"
      - Set dimensions according to item's importance and size
        - Most items should probably be 64x64. 
        - Guns and larger items can go up to 128x128
        - Smaller pickups can go down to 32x32 or 32x64
      - Set generated type to UV or Color grid
      - Click Create Image and save
    - Change material base color to use generated image texture
    - [unwrap using Pixel Unwrapper](https://github.com/noio/Pixel-Unwrapper?tab=readme-ov-file#unwrap-basic)
      - Make sure the texture pixels look square. If they don't its probably because you have an unapplied transform or something
- Texturing
  - There are a couple main approaches.
  - Reference Images
    - Pull reference images
    - Map UVs to the images
    - Downres the images using img2Pixel to match the rest of the game
    - Be careful of copyright
  - Reference Brushes
    - cut small bits of a reference image to import as a brush
    - Be sure to use img2Pixel to collapse the color space
  - Just do texture painting
    - The resolutions we're working at mean you can reasonably just hand paint your texture.
  - *Be sure to save the image!*
    - Blender doesn't save open images when you save the projeect, you have to save them manually
