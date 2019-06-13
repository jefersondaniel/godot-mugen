/*
 * Nomen - a New Opensource Mugen Editor by Nobun
 *
 *
 *  Copyright (C) 2011  Nobun
 *  http://mugenrebirth.forumfree.it
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program (GPL.txt).  If not, see <http://www.gnu.org/licenses/>.
 *
 ******************************************************/

//#include <QGraphicsPixmapItem>

#include "nomenSffFunctions.h"

bool nomenComparePalettes(ByteArray& pal1, ByteArray& pal2)
{
    if (pal1->size() != pal2->size()) {
        return false;
    }

    for (int a = 0; a < pal1.size(); a++) {
        if (pal1[a] != pal2[a]) {
            return false;
        }
    }

    return true;
}

//loading / saving Palettes:

ByteArray nomenLoadPal_pal(String filename)
{
    ByteArray pal;
    printf("TODO: nomenLoadPal_pal\n");
    return pal;
    //ByteArray pal;
    //QFile infile(filename);
    //infile.open(QIODevice::ReadOnly | QIODevice::Text);
    //QTextStream in(&infile);
    //QString tmp = in.readLine(); //JASC-PAL
    //if (tmp.compare(QString("JASC-PAL")) != 0)
    //    return pal;
    //tmp = in.readLine(); //0100
    //tmp = in.readLine(); //256 (colori palette)
    //while (!in.atEnd()) {
    //    tmp = in.readLine(); //R G B -> valore numerico R, G, B del colore
    //    QStringList strcolor = tmp.split(" ");
    //    strcolor[0] = strcolor[0].trimmed(); //remove spaces and returns
    //    strcolor[1] = strcolor[1].trimmed();
    //    strcolor[2] = strcolor[2].trimmed();
    //    quint8 r = (quint8)strcolor[0].toInt();
    //    quint8 g = (quint8)strcolor[1].toInt();
    //    quint8 b = (quint8)strcolor[2].toInt();
    //    pal.append(qRgb(r, g, b));
    //}
    //infile.close();
    //return pal;
}

ByteArray nomenLoadPal_act(String filename)
{
    ByteArray pal;
    printf("TODO: nomenLoadPal_act\n");
    return pal;
    /*
    QVector<QRgb> pal;
    QFile infile(filename);
    infile.open(QIODevice::ReadOnly);
    QDataStream in(&infile);
    quint8 r, g, b;

    for (int a = 0; a < 256; a++) {
        in >> r;
        in >> g;
        in >> b;
        pal.prepend(qRgb(r, g, b)); //act reverse the color order
    }
    infile.close();
    return pal;
    */
}
