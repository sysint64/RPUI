/**
 * Copyright: © 2017 RedGoosePaws
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 * Authors: Andrey Kabylin
 */

module resources.shaders;

import gapi.shader;
import application;

final class ShadersRes {
    Shader getShader(in string name) {
        return shaders[name];
    }

    Shader addShader(in string name, in string fileName) {
        shaders[name] = Shader.createFromFile(fileName);
        return shaders[name];
    }

private:
    Shader[string] shaders;
}
