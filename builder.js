const express = require("express")
const Jimp = require("jimp")

const app = express()
const port = 3000

app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb' }));

app.get('/', (req, res) => {
    res.send('Hello World!')
})

app.post("/Image", (req, res) => {

    if (typeof (req.body) != "object" || typeof (req.body[0]) != "object") throw TypeError("Expected an Array");

    let imagedata = req.body
    let image = new Jimp(imagedata.length, imagedata[1].length, function (err, _) {
        if (err) throw err;
    })

    imagedata.forEach((row, x) => {
        row.forEach((color, y) => {

            color.push(255)
            image.setPixelColor(Jimp.rgbaToInt(...color), x, y)
        })
    });

    image.write("image.jpeg")

    res.send("Finished building the Image!")
})

app.listen(port, () => {
    console.log(`App listening at http://localhost:${port}`)
})