# Contenu : ressources, familles et abeilles

Document de travail (brouillon, pas encore intégré à `DESIGN.md`). Il part de zéro, sans tenir compte de l'existant. Inspirations : APICO, Forestry, Resourceful/Productive Bees, Stardew Valley, apiary-old.

## Règles

- Une famille a plusieurs abeilles.
- Chaque abeille produit des ressources.
- Au sein d'une famille, toutes les abeilles ne produisent pas les mêmes ressources, mais certaines sont partagées.
- Une ressource peut être produite par plusieurs abeilles, mais toujours d'une seule et même famille.
- Une abeille de plus haut niveau peut produire des ressources de plus haut palier, pas forcément du palier 1.
- Les règles de production ne sont pas fixes : elles dépendent de chaque famille.
- Une seule espèce d'abeille par niveau dans une famille.
- Fusionner 2 ressources identiques donne le palier suivant. Fusionner 2 abeilles identiques donne l'abeille du niveau suivant de leur famille.
- Certaines familles ne s'obtiennent que par l'incubateur (croisement de deux abeilles différentes).
- Noms d'abeilles : simples, « Abeille + qualificatif » (commune, charpentière, buissonnière…), dérivés de la ressource principale, jamais « de/des/de la ».

## Branches de ressources (16 branches, 81 ressources)

| Branche | Chaîne |
|---|---|
| **Cire** | Goutte de cire → Cire brute → Cire raffinée → Bougie |
| **Miel** | Nectar → Miel clair → Miel ambré → Miel doré |
| **Fleurs** | Pâquerette → Perce-neige → Bleuet → Jonquille → Tulipe → Œillet → Lilas → Camélia |
| **Fruits** | Myrtille → Fraise → Framboise → Cerise → Raisin → Pomme → Orange → Pomme dorée |
| **Herbes** | Brin d'herbe → Menthe → Ciboulette → Persil → Basilic → Thym → Romarin → Lavande |
| **Champignons** | Spore → Champignon de Paris → Amanite tue-mouches → Lactaire indigo → Améthyste → Cèpe → Truffe |
| **Bois** | Brindille → Branche → Bûche → Planche |
| **Résine** | Sève → Résine → Copal → Ambre |
| **Terre** | Terre → Sable → Gravier → Pierre |
| **Cuivre** | Minerai de cuivre → Lingot → Plaque → Fil |
| **Fer** | Minerai de fer → Lingot → Barre → Outil |
| **Étain** | Minerai d'étain → Lingot → Plaque → Gobelet |
| **Argent** | Minerai d'argent → Lingot → Fil → Couverts |
| **Or** | Minerai d'or → Lingot → Feuille d'or → Couronne |
| **Eau** | Rosée → Eau de source → Eau salée → Sel |
| **Poissons** | Vairon → Sardine → Perche → Truite → Saumon → Esturgeon |

Notes :

- Herbes : 8 paliers d'aromates (Infusion et Remède retirés pour le moment ; ils pourront revenir comme produits transformés).
- Champignons : 7 paliers (Marron retiré). Terre : 4 paliers (Argile retirée).
- Fleurs, fruits et champignons s'inspirent des sprites Stardew fournis (du plus commun au plus prestigieux). Idée pour plus tard : variantes de couleur d'une même fleur (tulipes rose, rouge, jaune…), par exemple via mutation.
- Fruits exotiques de la liste Stardew (banane, noix de coco, kiwi, fruit de l'étoile, vanille…) : réserve pour une branche à part.
- Cèpe et truffe sont des ajouts hors des sprites fournis.

## Familles

| Famille | Obtention | Branches | Ressources | Abeilles |
|---|---|---|---|---|
| **Mellifère** | Reine | Cire, Miel | 8 | 4 |
| **Forestière** | Reine | Bois, Résine | 8 | 3 |
| **Mineuse** | Reine | Terre | 4 | 4 |
| **Florale** | Reine | Fleurs, Herbes | 16 | 6 |
| **Fruitière** | Incubateur (niveau 1) | Fruits | 8 | 6 |
| **Aquatique** | Reine | Eau, Poissons | 10 | 5 |
| **Métallière** | Incubateur (niveau 1) | Cuivre, Fer, Étain, Argent, Or | 20 | 5 |
| **Mycélienne** | Incubateur (niveau 1) | Champignons | 7 | 5 |

Total : 38 abeilles. Trois familles viennent de l'incubateur (Fruitière, Métallière, Mycélienne), cinq d'une reine (Mellifère, Forestière, Mineuse, Florale, Aquatique). Pour une famille « Incubateur », seule l'abeille de niveau 1 s'obtient en croisant deux abeilles ; les niveaux suivants s'obtiennent par fusion, comme partout.

## Abeilles par famille

Convention de lecture : sauf mention contraire, l'abeille de niveau N produit le palier N de ses branches, plus le palier N-1. Les paliers les plus hauts ne s'obtiennent que par fusion.

### Mellifère (validé)

| Niv. | Abeille | Cire | Miel |
|---|---|---|---|
| **1** | Abeille commune | Goutte de cire | Nectar |
| **2** | Abeille ouvrière | Cire brute, Goutte de cire | Miel clair, Nectar |
| **3** | Abeille cirière | Cire raffinée, Cire brute | Miel ambré, Miel clair |
| **4** | Abeille dorée | Cire raffinée | Miel doré, Miel ambré |

Bougie : fusion uniquement. Le niveau 4 est la seule abeille qui produit du miel doré.

### Forestière (validé)

| Niv. | Abeille | Bois | Résine |
|---|---|---|---|
| **1** | Abeille buissonnière | Brindille | Sève |
| **2** | Abeille résinière | Branche, Brindille | Résine, Sève |
| **3** | Abeille charpentière | Bûche, Branche | Copal, Résine |

Planche et ambre : fusion uniquement. Les champignons ont quitté la famille. L'abeille écorcière est remplacée par la résinière (nom de apiary-old), puisqu'il n'y a plus d'écorce.

### Mineuse (validé)

| Niv. | Abeille | Terre |
|---|---|---|
| **1** | Abeille fouisseuse | Terre |
| **2** | Abeille sableuse | Sable, Terre |
| **3** | Abeille maçonne | Gravier, Sable |
| **4** | Abeille mineuse | Pierre, Gravier |

Les branches Cuivre et Fer sont passées à la famille Métallière (une ressource appartient à une seule famille).

### Recettes d'incubateur (validé)

Chaque famille « Incubateur » combine deux familles à reine. Un croisement donne toujours la même espèce.

| Résultat (niveau 1) | Parent A | Parent B | Idée |
|---|---|---|---|
| **Abeille myrtillière** (Fruitière) | Abeille printanière (Florale 2) | Abeille buissonnière (Forestière 1) | La fleur du printemps + le buisson donnent la baie. |
| **Abeille lichéenne** (Mycélienne) | Abeille charpentière (Forestière 3) | Abeille sourcière (Aquatique 2) | Le lichen vit sur le bois, nourri par l'eau de source. |
| **Abeille cuivrée** (Métallière) | Abeille mineuse (Mineuse 4) | Abeille dorée (Mellifère 4) | La roche et l'éclat du miel doré donnent le métal. |

Les deux parents de la cuivrée sont de niveau 4 (le plus haut de leur famille), ce qui rend la Métallière nettement plus tardive que la Fruitière et la Mycélienne.

### Métallière (validé)

Famille obtenue par l'incubateur (voir les recettes) : l'abeille de niveau 1 (cuivrée) sort d'un croisement, les suivantes par fusion.

| Niv. | Abeille | Minerais produits |
|---|---|---|
| **1** | Abeille cuivrée | Minerai de cuivre |
| **2** | Abeille ferrière | Minerai de fer |
| **3** | Abeille étamière | Minerai d'étain |
| **4** | Abeille argentière | Minerai d'argent |
| **5** | Abeille aurifère | Minerai d'or |

Seuls les minerais (palier 1) sont produits ; lingots et formes viennent de la fusion. Chaque abeille ne produit que son propre minerai, pas ceux des niveaux précédents (exception à la règle générale « palier N plus N-1 »).

### Mycélienne (validé)

Famille obtenue par l'incubateur, comme la Métallière. Les champignons quittent la Forestière.

| Niv. | Abeille | Champignons |
|---|---|---|
| **1** | Abeille lichéenne | Spore |
| **2** | Abeille moussue | Champignon de Paris, Spore |
| **3** | Abeille mycélienne | Amanite tue-mouches, Champignon de Paris |
| **4** | Abeille sylvestre | Lactaire indigo, Amanite tue-mouches |
| **5** | Abeille souterraine | Améthyste, Lactaire indigo |

Cèpe et truffe : fusion uniquement. Noms proposés (lichéenne et mycélienne viennent de apiary-old).

### Florale (validé)

| Niv. | Abeille | Fleurs | Herbes |
|---|---|---|---|
| **1** | Abeille herbacée | Pâquerette | Brin d'herbe |
| **2** | Abeille printanière | Perce-neige, Pâquerette | Menthe, Brin d'herbe |
| **3** | Abeille butineuse | Bleuet, Perce-neige | Ciboulette, Menthe |
| **4** | Abeille jardinière | Jonquille, Bleuet | Persil, Ciboulette |
| **5** | Abeille parfumée | Tulipe, Jonquille | Basilic, Persil |
| **6** | Abeille herboriste | Œillet, Tulipe | Thym, Basilic |

Lilas, camélia, romarin et lavande : fusion uniquement.

### Fruitière (validé)

| Niv. | Abeille | Fruits |
|---|---|---|
| **1** | Abeille myrtillière | Myrtille |
| **2** | Abeille gourmande | Fraise, Myrtille |
| **3** | Abeille cueilleuse | Framboise, Fraise |
| **4** | Abeille cerisière | Cerise, Framboise |
| **5** | Abeille vigneronne | Raisin, Cerise |
| **6** | Abeille pommière | Pomme, Raisin |

Orange et pomme dorée : fusion uniquement. Pas d'abeille de niveau 7.

### Aquatique (validé)

| Niv. | Abeille | Eau | Poissons |
|---|---|---|---|
| **1** | Abeille matinale | Rosée | Vairon |
| **2** | Abeille sourcière | Eau de source, Rosée | Sardine, Vairon |
| **3** | Abeille marine | Eau salée, Eau de source | Perche, Sardine |
| **4** | Abeille pêcheuse | | Truite, Perche |
| **5** | Abeille saumonière | | Saumon, Truite |

Sel et esturgeon : fusion uniquement.

## Durée de vie des abeilles

Exprimée en nombre de ressources produites en ruche (hypothèse de travail, à tester en jeu).

- **Niveau 1 : 10 ressources.**
- **Croissance : × 1,5 par niveau**, arrondie (à tester ; × 1,4 ou +8 par niveau sont des alternatives).
- **Variation : ± 20 %** autour de la valeur du niveau (une abeille de niveau 1 vit donc 8 à 12 ressources).
- Le hasard n'est pas tiré à la naissance : la durée de vie est fixée **la première fois que l'abeille produit une ressource en ruche**, et reste invisible pour le joueur.

| Niveau | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|
| Durée de vie moyenne | 10 | 15 | 23 | 34 | 51 | 76 |
| Fourchette (± 20 %) | 8 à 12 | 12 à 18 | 18 à 28 | 27 à 41 | 41 à 61 | 61 à 91 |

## Décisions

- Pas d'abeille de niveau 7 en Fruitière : la pomme dorée reste un palier de fusion.
- Cuivre et fer quittent Mineuse pour une nouvelle famille Métallière, obtenue par l'incubateur, qui monte jusqu'à l'or.
- Les champignons quittent Forestière pour une nouvelle famille Mycélienne, obtenue par l'incubateur.
- Métallière : abeille de niveau 2 nommée ferrière, métaux cuivre, fer, étain, argent, or, formes des paliers 3 et 4 validées.
- Revue de progression : la Métallière ne produit que des minerais (palier 1), c'est voulu. Mineuse reste le parent de la cuivrée (pas de maçonne). Fleurs, herbes et fruits restent à 8 paliers, à réévaluer en jeu.
- Une famille à incubateur reste lourde à monter tant que sa reine n'est pas débloquée : la reine de l'espèce mutée est une récompense de fin de journée après la découverte (voir DESIGN.md), il peut donc falloir plusieurs incubations avant de la recevoir.
- Métallière : chaque abeille ne produit que son propre minerai (pas ceux des niveaux précédents).
- Durée de vie des abeilles : voir la section « Durée de vie » ci-dessous (la valeur de 5 du DESIGN était jugée trop courte).

## Questions ouvertes

- Durée d'incubation et calendrier des reines de fin de journée : décident du rythme réel des familles à incubateur.
- Indexer les récompenses des commandes sur le coût réel (2^(palier−1) ressources de palier 1) plutôt que sur le numéro de palier.

## À ajouter plus tard

- Infusion et Remède (produits transformés).
- Fruits exotiques (branche à part).
