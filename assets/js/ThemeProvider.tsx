import * as React from "react"
import { MuiThemeProvider, createMuiTheme, Theme } from '@material-ui/core/styles';


const theme: Theme = createMuiTheme(
    {
        palette: {
            primary: {
                light: "blue",
                main: "#3668D3",
                dark: "#1F50B8",
                contrastText: "#fff",
            },
        }
    }
);


export const ThemeProvider = (props: any) => (
    <MuiThemeProvider theme={theme}>
        {props.children}
    </MuiThemeProvider>
)
