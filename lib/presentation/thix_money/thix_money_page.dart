import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThixMoneyPage extends StatefulWidget {
  const ThixMoneyPage({super.key});

  @override
  State<ThixMoneyPage> createState() =>
      _ThixMoneyPageState();
}

class _ThixMoneyPageState
    extends State<ThixMoneyPage> {
  int currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xffF5F7FB),

      bottomNavigationBar: _bottomNavigation(),

      body: SafeArea(
        child: SingleChildScrollView(
          physics:
              const ClampingScrollPhysics(),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            child: Column(
              children: [
                /// HEADER
                Row(
                  children: [
                    Icon(
                      Icons.menu_rounded,
                      size: 28,
                      color: const Color(
                          0xff111827),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'THIX ',
                                  style:
                                      GoogleFonts
                                          .poppins(
                                    fontSize:
                                        20,
                                    fontWeight:
                                        FontWeight
                                            .w800,
                                    color: const Color(
                                        0xff111827),
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      'MONEY',
                                  style:
                                      GoogleFonts
                                          .poppins(
                                    fontSize:
                                        20,
                                    fontWeight:
                                        FontWeight
                                            .w800,
                                    color: const Color(
                                        0xff2563FF),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Text(
                            'Votre argent, votre liberté.',
                            style:
                                GoogleFonts
                                    .poppins(
                              fontSize: 12,
                              color:
                                  Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Stack(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration:
                              BoxDecoration(
                            color:
                                Colors.white,
                            shape:
                                BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors
                                    .black
                                    .withOpacity(
                                        .03),
                                blurRadius:
                                    8,
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons
                                .notifications_none_rounded,
                            size: 24,
                          ),
                        ),

                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration:
                                const BoxDecoration(
                              color:
                                  Colors.red,
                              shape: BoxShape
                                  .circle,
                            ),
                            child: Center(
                              child: Text(
                                '3',
                                style:
                                    GoogleFonts
                                        .poppins(
                                  fontSize:
                                      9,
                                  color: Colors
                                      .white,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(width: 10),

                    Container(
                      width: 50,
                      height: 50,
                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,
                        image:
                            const DecorationImage(
                          image: NetworkImage(
                            'https://i.pravatar.cc/300',
                          ),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors
                                .black
                                .withOpacity(
                                    .05),
                            blurRadius: 10,
                          )
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                /// BALANCE CARD
                Container(
                  height: 140,
                  padding:
                      const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(
                            28),
                    gradient:
                        const LinearGradient(
                      begin:
                          Alignment.topLeft,
                      end: Alignment
                          .bottomRight,
                      colors: [
                        Color(0xff020B56),
                        Color(0xff001B8D),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue
                            .withOpacity(.18),
                        blurRadius: 18,
                        offset:
                            const Offset(
                                0, 8),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Solde disponible',
                                  style:
                                      GoogleFonts.poppins(
                                    color: Colors
                                        .white70,
                                    fontSize:
                                        14,
                                  ),
                                ),

                                const SizedBox(
                                    width:
                                        8),

                                const Icon(
                                  Icons
                                      .visibility_outlined,
                                  color: Colors
                                      .white70,
                                  size: 18,
                                ),
                              ],
                            ),

                            const SizedBox(
                                height:
                                    14),

                            Text(
                              '1.250.000 FC',
                              style:
                                  GoogleFonts
                                      .poppins(
                                color: Colors
                                    .white,
                                fontSize:
                                    16,
                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),

                            const SizedBox(
                                height:
                                    6),

                            Text(
                              '≈ 625,00 USD',
                              style:
                                  GoogleFonts
                                      .poppins(
                                color: Colors
                                    .white70,
                                fontSize:
                                    14,
                              ),
                            ),

                            const Spacer(),

                            Row(
                              children: [
                                _miniButton(
                                  Icons
                                      .history,
                                  'Historique',
                                ),

                                const SizedBox(
                                    width:
                                        10),

                                Container(
                                  width:
                                      48,
                                  height:
                                      48,
                                  decoration:
                                      BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(
                                            16),
                                    border:
                                        Border.all(
                                      color: Colors
                                          .white24,
                                    ),
                                  ),
                                  child:
                                      const Icon(
                                    Icons
                                        .more_horiz,
                                    color: Colors
                                        .white,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      /// VISA CARD
                      Container(
                        width: 140,
                        decoration:
                            BoxDecoration(
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      22),
                          gradient:
                              const LinearGradient(
                            colors: [
                              Color(
                                  0xff020817),
                              Color(
                                  0xff0B1437),
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -16,
                              top: -16,
                              child:
                                  Container(
                                width:
                                    100,
                                height:
                                    100,
                                decoration:
                                    BoxDecoration(
                                  shape: BoxShape
                                      .circle,
                                  color: Colors
                                      .amber
                                      .withOpacity(
                                          .05),
                                ),
                              ),
                            ),

                            Padding(
                              padding:
                                  const EdgeInsets
                                      .all(
                                      16),
                              child:
                                  Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'THIX ID',
                                    style:
                                        GoogleFonts.poppins(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),

                                  const Spacer(),

                                  Row(
                                    children: [
                                      Container(
                                        width:
                                            34,
                                        height:
                                            24,
                                        decoration:
                                            BoxDecoration(
                                          color: Colors.amber,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),

                                      const SizedBox(
                                          width:
                                              10),

                                      const Icon(
                                        Icons.wifi,
                                        color: Colors.amber,
                                        size: 18,
                                      )
                                    ],
                                  ),

                                  const Spacer(),

                                  Align(
                                    alignment:
                                        Alignment.bottomRight,
                                    child:
                                        Text(
                                      'NFC PAYE',
                                      style:
                                          GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                /// ACTIONS
                Row(
                  children: [
                    Expanded(
                      child: _actionCard(
                        color:
                            const Color(
                                0xff2563FF),
                        icon:
                            Icons.north_east,
                        title:
                            'Envoyer',
                        subtitle:
                            'Vers un contact\nou un compte',
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _actionCard(
                        color:
                            const Color(
                                0xff16A34A),
                        icon:
                            Icons.add,
                        title:
                            'Recharger',
                        subtitle:
                            'Depuis carte ou\nMobile Money',
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _actionCard(
                        color:
                            const Color(
                                0xff7C3AED),
                        icon:
                            Icons.qr_code_scanner,
                        title:
                            'Scanner QR',
                        subtitle:
                            'Payer ou recevoir\nrapidement',
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _actionCard(
                        color:
                            const Color(
                                0xffF59E0B),
                        icon:
                            Icons.wallet,
                        title:
                            'Retrait',
                        subtitle:
                            'Chez agent ou\nvers réseau tiers',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                /// QUICK PAYMENTS
                Container(
                  padding:
                      const EdgeInsets.all(
                          18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                            24),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                        children: [
                          Text(
                            'Paiements rapides',
                            style:
                                GoogleFonts
                                    .poppins(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),

                          Row(
                            children: [
                              Text(
                                'Voir tout',
                                style:
                                    GoogleFonts.poppins(
                                  fontSize:
                                      12,
                                  color: Colors.grey,
                                ),
                              ),

                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                              )
                            ],
                          )
                        ],
                      ),

                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceAround,
                        children: [
                          _paymentItem(
                            Icons.receipt,
                            'Payer une\nfacture',
                            const Color(
                                0xff2563FF),
                          ),

                          _paymentItem(
                            Icons.groups,
                            'THIX\nTontine',
                            const Color(
                                0xff16A34A),
                          ),

                          _paymentItem(
                            Icons.lightbulb,
                            'Électricité',
                            const Color(
                                0xffF59E0B),
                          ),

                          _paymentItem(
                            Icons.water_drop,
                            'Eau',
                            const Color(
                                0xff2563FF),
                          ),

                          _paymentItem(
                            Icons.tv,
                            'TV &\nInternet',
                            const Color(
                                0xffEC4899),
                          ),

                          _paymentItem(
                            Icons.more_horiz,
                            'Autres\nservices',
                            Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// THIX CARD
                Container(
                  height: 140,
                  padding:
                      const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                            24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              'Carte THIX ID',
                              style:
                                  GoogleFonts
                                      .poppins(
                                fontSize:
                                    18,
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),

                            const SizedBox(
                                height:
                                    8),

                            Text(
                              'Payez partout avec votre carte\nTHIX ID Visa.',
                              style:
                                  GoogleFonts
                                      .poppins(
                                fontSize:
                                    13,
                                color: Colors
                                    .grey,
                              ),
                            ),

                            const Spacer(),

                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal:
                                    20,
                                vertical:
                                    12,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: const Color(
                                    0xff0B1F8F),
                                borderRadius:
                                    BorderRadius.circular(
                                        16),
                              ),
                              child: Text(
                                'Voir ma carte',
                                style:
                                    GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child:
                                  Container(
                                decoration:
                                    BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  gradient:
                                      const LinearGradient(
                                    colors: [
                                      Color(0xff020817),
                                      Color(0xff0B1437),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                                height:
                                    10),

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius:
                                      18,
                                  backgroundColor:
                                      const Color(0xff0B1F8F),
                                  child:
                                      const Icon(
                                    Icons
                                        .verified,
                                    color: Colors
                                        .white,
                                    size: 18,
                                  ),
                                ),

                                const SizedBox(
                                    width:
                                        8),

                                Expanded(
                                  child:
                                      Text(
                                    'Sécurisée\net acceptée partout',
                                    style:
                                        GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// GIFTS
                SizedBox(
                  height: 130,
                  child: ListView(
                    scrollDirection:
                        Axis.horizontal,
                    children: [
                      _giftCard(
                        bg:
                            const Color(
                                0xff001B8D),
                        title:
                            'THIX Tontine',
                        subtitle:
                            'Épargnez, cotisez et atteignez\nvos objectifs.',
                        button:
                            'Rejoindre',
                      ),

                      const SizedBox(width: 14),

                      _giftCard(
                        bg:
                            const Color(
                                0xffEAF8EE),
                        title:
                            'Parrainez & gagnez',
                        subtitle:
                            'Invitez vos proches et\ngagnez des récompenses.',
                        button:
                            'Inviter',
                        dark: false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// MORE SERVICES
                Container(
                  padding:
                      const EdgeInsets.all(
                          18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                            24),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        'Plus de services',
                        style:
                            GoogleFonts
                                .poppins(
                          fontSize: 18,
                          fontWeight:
                              FontWeight
                                  .w700,
                        ),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceAround,
                        children: [
                          _miniService(
                              Icons.security,
                              'Assurance'),
                          _miniService(
                              Icons.bar_chart,
                              'Investir'),
                          _miniService(
                              Icons.discount,
                              'Coupons'),
                          _miniService(
                              Icons.receipt_long,
                              'Relevés'),
                          _miniService(
                              Icons.support_agent,
                              'Support'),
                          _miniService(
                              Icons.more_horiz,
                              'Plus'),
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniButton(
      IconData icon, String text) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white24,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),

          const SizedBox(width: 8),

          Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight:
                  FontWeight.w500,
            ),
          )
        ],
      ),
    );
  }

  Widget _actionCard({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      height: 210,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              height: 1.5,
              color: Colors.grey,
            ),
          )
        ],
      ),
    );
  }

  Widget _paymentItem(
    IconData icon,
    String text,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withOpacity(.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 11,
            height: 1.5,
            fontWeight:
                FontWeight.w500,
          ),
        )
      ],
    );
  }

  Widget _giftCard({
    required Color bg,
    required String title,
    required String subtitle,
    required String button,
    bool dark = true,
  }) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius:
            BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  title,
                  style:
                      GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w700,
                    color: dark
                        ? Colors.white
                        : Colors.green,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  subtitle,
                  style:
                      GoogleFonts.poppins(
                    fontSize: 13,
                    height: 1.6,
                    color: dark
                        ? Colors.white70
                        : Colors.black87,
                  ),
                ),

                const Spacer(),

                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration:
                      BoxDecoration(
                    color: dark
                        ? Colors.white
                        : Colors.green,
                    borderRadius:
                        BorderRadius
                            .circular(
                                16),
                  ),
                  child: Text(
                    button,
                    style:
                        GoogleFonts
                            .poppins(
                      fontWeight:
                          FontWeight
                              .w600,
                      color: dark
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),

          Container(
            width: 95,
            decoration:
                BoxDecoration(
              borderRadius:
                  BorderRadius
                      .circular(18),
              color: Colors.white
                  .withOpacity(.08),
            ),
          )
        ],
      ),
    );
  }

  Widget _miniService(
      IconData icon, String text) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color:
                const Color(0xffF5F7FB),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 22,
            color:
                const Color(0xff2563FF),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight:
                FontWeight.w500,
          ),
        )
      ],
    );
  }

  Widget _bottomNavigation() {
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
                    .05),
            blurRadius: 20,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment
                .spaceAround,
        children: [
          _navItem(
              Icons.home_rounded,
              'Accueil',
              0),

          _navItem(
              Icons.sync_alt_rounded,
              'Transactions',
              1),

          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient:
                  const LinearGradient(
                colors: [
                  Color(0xff2563FF),
                  Color(0xff0047FF),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue
                      .withOpacity(.35),
                  blurRadius: 18,
                )
              ],
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment
                      .center,
              children: [
                const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 28,
                ),

                const SizedBox(height: 4),

                Text(
                  'Scanner\nQR',
                  textAlign:
                      TextAlign.center,
                  style:
                      GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight:
                        FontWeight.w500,
                  ),
                )
              ],
            ),
          ),

          _navItem(
              Icons.credit_card_outlined,
              'Cartes',
              3),

          _navItem(
              Icons.person_outline,
              'Profil',
              4),
        ],
      ),
    );
  }

  Widget _navItem(
      IconData icon,
      String title,
      int index) {
    final active =
        currentIndex == index;

    return Column(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 24,
          color: active
              ? const Color(
                  0xff2563FF)
              : Colors.grey,
        ),

        const SizedBox(height: 5),

        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight:
                FontWeight.w500,
            color: active
                ? const Color(
                    0xff2563FF)
                : Colors.grey,
          ),
        )
      ],
    );
  }
}
