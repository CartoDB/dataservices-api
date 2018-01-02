import plpy


class PolyLine:
    """ Polyline decoder https://developers.google.com/maps/documentation/utilities/polylinealgorithm?csw=1 """

    def decode(self, data):
        coordinates = []
        chunks = self._extract_chunks(data)
        for chunk in chunks:
            coordinate = self._process_chunk(chunk)
            coordinate /= 1e5
            if len(coordinates) > 1:
                # We have to sum the previous with the offset in this chunk
                coordinate += coordinates[-2]
            coordinates.append(round(coordinate, 5))

        return zip(coordinates, coordinates[1:])[::2]

    def _extract_chunks(self, data):
        chunks, chunk = [], []
        for character in data:
            byte = ord(character) - 63
            if byte & 0x20 > 0:
                byte &= 0x1F
                chunk.append(byte)
            else:
                chunk.append(byte)
                chunks.append(chunk)
                chunk = []

        return chunks

    def _process_chunk(self, chunk):
        coordinate = self._get_coordinate(chunk)
        # Check if the coordinate is negative
        if coordinate & 0x1:
            return ~(coordinate >> 1)
        else:
            return coordinate >> 1

    def _get_coordinate(self, chunk):
        coordinate = 0
        for i, c in enumerate(chunk):
            coordinate |= c << (i * 5)

        return coordinate


def polyline_to_linestring(polyline):
    """Convert a Mapzen polyline shape to a PostGIS linestring"""
    coordinates = []
    for point in polyline:
        # Divide by 10 because mapzen uses one more decimal than the
        # google standard (https://mapzen.com/documentation/turn-by-turn/decoding/)
        coordinates.append("%s %s" % (point[1]/10, point[0]/10))
    wkt_coordinates = ','.join(coordinates)

    try:
        sql = "SELECT ST_GeomFromText('LINESTRING({0})', 4326) as geom".format(wkt_coordinates)
        geometry = plpy.execute(sql, 1)[0]['geom']
    except BaseException as e:
        plpy.warning("Can't generate LINESTRING from polyline: {0}".format(e))
        geometry = None

    return geometry
