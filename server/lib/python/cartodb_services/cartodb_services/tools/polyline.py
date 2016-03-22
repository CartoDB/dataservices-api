from itertools import tee, izip
from math import trunc


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
