module ui.theme;

import e2ml;
import gapi;


class Theme {
    @property e2ml.Data atlasData() { return p_atlasData; }
    @property gapi.Texture skin() { return p_skin; }

private:
    e2ml.Data p_atlasData;
    gapi.Texture p_skin;
}
