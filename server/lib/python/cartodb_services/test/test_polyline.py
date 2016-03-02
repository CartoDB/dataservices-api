from cartodb_services.tools import PolyLine
from unittest import TestCase


class TestPolyline(TestCase):

    def setUp(self):
        self.polyline = PolyLine()

    def test_should_decode_a_chunk_correctly(self):
        decoded_polyline = self.polyline.decode('`~oia@`~oia@')
        original_value = [(-179.98321, -179.98321)]

        assert decoded_polyline == original_value

    def test_should_decode_polyline_correctly(self):
        original_polyline_1 = [(38.5, -120.2),
                             (40.7, -120.95),
                             (43.252, -126.453)]
        decoded_polyline_1 = self.polyline.decode('_p~iF~ps|U_ulLnnqC_mqNvxq`@')

        assert decoded_polyline_1 == original_polyline_1

        original_polyline_2 = [(17.95783,-5.58105),
                             (15.79225,2.90039),
                             (7.60211,-10.76660)]
        decoded_polyline_2 = self.polyline.decode('mkrlBp`aa@z}eL_pwr@js~p@tilrA')

        assert decoded_polyline_2 == original_polyline_2

        original_polyline_3 = [(62.75473,-157.14844),
                             (65.07213,169.80469) ,
                             (48.92250,158.55469),
                             (44.33957,-150.46875)]
        decoded_polyline_3 = self.polyline.decode('ax_~Jv`d~\wrcMa`qj}@dfqaBngtcAhb~Zncc}y@')

        assert decoded_polyline_3 == original_polyline_3


