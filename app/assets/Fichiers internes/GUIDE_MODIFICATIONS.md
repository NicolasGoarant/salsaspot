# SalsaSpot — Guide des modifications

## Résumé des changements

### 1. SEO (meta tags Open Graph + Twitter Card)
**Fichier modifié :** `app/views/layouts/application.html.erb`

Le layout application inclut maintenant :
- `<meta name="description">` dynamique via `content_for(:meta_description)`
- Balises Open Graph complètes (og:title, og:description, og:image, og:url, og:locale)
- Twitter Card (summary_large_image)
- Lien canonical
- Titre par défaut optimisé : "SalsaSpot — Trouve ta soirée salsa, bachata, kizomba"

**Usage dans les vues :** chaque page peut définir ses propres meta via `content_for`. Exemple :
```erb
<% content_for(:title) { "Contact - SalsaSpot" } %>
<% content_for(:meta_description) { "Contactez l'équipe SalsaSpot..." } %>
```

> **Note :** La page events/show.html.erb a déjà ses propres OG tags (elle reste en `layout: false`), donc pas de doublon.

---

### 2. Pages légales et contact avec navbar + footer
**Fichier modifié :** `app/controllers/pages_controller.rb`

- `about` et `discover` restent en `layout: false` (ce sont des landing pages standalone avec leur propre design)
- `contact`, `mentions_legales`, `cgu`, `politique_confidentialite` utilisent maintenant le layout application → elles ont la navbar et le footer automatiquement

**Fichiers modifiés (vues) :**
- `app/views/pages/mentions_legales.html.erb` → contenu seul, plus de `<html>/<head>/<body>`
- `app/views/pages/cgu.html.erb` → idem
- `app/views/pages/politique_confidentialite.html.erb` → idem
- `app/views/pages/contact.html.erb` → idem

Les styles spécifiques aux pages de contenu (`.page-container`, `.contact-grid`, `.faq-section`, etc.) sont ajoutés dans le layout application.

---

### 3. Layout admin partagé (suppression CSS dupliqué)
**Nouveau fichier :** `app/views/layouts/admin.html.erb`

Contient tout le CSS admin partagé (~250 lignes au lieu de ~1200 dupliquées). Inclut `<meta name="robots" content="noindex, nofollow">` pour éviter l'indexation.

**Fichier modifié :** `app/controllers/admin/events_controller.rb`
- Remplacé `layout false` par `layout 'admin'`
- Corrigé le bug `file` avant `params[:file]` dans `import_excel`
- Ajouté des champs manquants dans `event_params` : `:website`, `:organizer_email`, `:phone`, `:recurrence`, `:postal_code`

**Fichiers modifiés (vues admin) — contenu seul, plus de `<html>` wrapper :**
- `app/views/admin/events/index.html.erb`
- `app/views/admin/events/show.html.erb`
- `app/views/admin/events/new.html.erb`
- `app/views/admin/events/edit.html.erb`
- `app/views/admin/events/import.html.erb`

---

### 4. Formulaire admin partagé (partial)
**Nouveau fichier :** `app/views/admin/events/_form.html.erb`

Corrections :
- `has_class` → `has_lessons` ✅
- `event_url` → `website` + ajout `facebook_url` ✅
- Ajout des champs manquants : `level` (select), `recurrence` (select), `lessons_time`, `is_free`, `organizer_name`, `organizer_email`, `phone`, `postal_code`
- Note "Calculée automatiquement si laissée vide" sous latitude/longitude (puisque Geocoder est configuré)

---

## Arborescence des fichiers à copier

```
app/
├── controllers/
│   ├── pages_controller.rb                    ← MODIFIÉ
│   └── admin/
│       └── events_controller.rb               ← MODIFIÉ
├── views/
│   ├── layouts/
│   │   ├── application.html.erb               ← MODIFIÉ (SEO + styles pages)
│   │   └── admin.html.erb                     ← NOUVEAU
│   ├── pages/
│   │   ├── mentions_legales.html.erb          ← MODIFIÉ (contenu seul)
│   │   ├── cgu.html.erb                       ← MODIFIÉ (contenu seul)
│   │   ├── politique_confidentialite.html.erb  ← MODIFIÉ (contenu seul)
│   │   └── contact.html.erb                   ← MODIFIÉ (contenu seul)
│   └── admin/
│       └── events/
│           ├── _form.html.erb                 ← NOUVEAU (partial partagé)
│           ├── index.html.erb                 ← MODIFIÉ (contenu seul)
│           ├── show.html.erb                  ← MODIFIÉ (contenu seul)
│           ├── new.html.erb                   ← MODIFIÉ (contenu seul)
│           ├── edit.html.erb                  ← MODIFIÉ (contenu seul)
│           └── import.html.erb                ← MODIFIÉ (contenu seul)
```

---

## Variables d'environnement Heroku

N'oublie pas de configurer sur Heroku :

```bash
heroku config:set ADMIN_USER=nicolas.goarant@hotmail.fr
heroku config:set ADMIN_PASSWORD=salsa2026
```

---

## Fichiers NON modifiés

Ces fichiers restent identiques (ils fonctionnent déjà bien) :
- `app/views/pages/about.html.erb` (landing page standalone)
- `app/views/pages/discover.html.erb` (landing page standalone)
- `app/views/events/index.html.erb` (page carte, layout: false)
- `app/views/events/show.html.erb` (page détail, layout: false, a déjà le SEO)
- `app/views/events/new.html.erb` (formulaire public)
- `app/models/event.rb` (déjà bien configuré)
- `config/routes.rb` (pas de changement nécessaire)
